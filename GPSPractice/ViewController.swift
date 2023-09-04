//
//  ViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/03.
//

import UIKit
import CoreLocation
import MapKit
import Combine

import RealmSwift

class ViewController: UIViewController {
    var locationManager: CLLocationManager!
    var previousCoordinate: CLLocationCoordinate2D?
    @Published var logOfSpeed: [Double]!
    var currentSpeed = CurrentValueSubject<CLLocationSpeed, Never>(0)
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var speedLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var averageSpeedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.showsUserLocation = true
        mapView.delegate = self
        logOfSpeed = []
        bind()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
    }

    private func bind() {
        currentSpeed
            .receive(on: RunLoop.main)
            .sink { [unowned self] speed in
                self.speedLabel.text = "\(speed)"
                logOfSpeed.append(speed)
            }.store(in: &subscriptions)

        $logOfSpeed
            .receive(on: DispatchQueue.global())
            .compactMap { $0 }
            .map { $0.filter { $0 > 0 } }
            .map { items -> Double in
                let count = Double(items.count)
                let averageSpeed = items.reduce(0.0, +) / count
                return round(averageSpeed * 10) / 10
            }
            .receive(on: RunLoop.main)
            .sink { [unowned self] averageSpeed in
                self.averageSpeedLabel.text = "\(averageSpeed)"
            }.store(in: &subscriptions)
    }

    private func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    private func startTracking() {
        locationManager.startUpdatingLocation()
    }

    //현재 위치로 이동
    @IBAction func locationButton(_ sender: Any) {
        setUserTrackingMode()
    }
    @IBAction func startTrackingButtonTapped(_ sender: Any) {
        startTracking()
    }
    @IBAction func stopTrackingButtonTapped(_ sender: Any) {
        stopTracking()
    }
    @IBAction func printButtonTapped(_ sender: Any) {
        guard let logOfSpeed else { return }
        print(logOfSpeed)
    }

    private func setUserTrackingMode() {
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            mapView.setUserTrackingMode(.follow, animated: true)
        }
    }

    private func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    private func showLocationDisabledAlert() {
        let alert = UIAlertController(title: "Location Access Disabled",
                                      message: "In order to measure speed we need your location",
                                      preferredStyle: .alert)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { action in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler:nil)
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(openAction)

        self.present(alert, animated:true, completion:nil)
    }
}

extension ViewController: CLLocationManagerDelegate {
    //MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let location = locations.last else { return }

        // 이동한 경로를 선으로 그려줌
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        if let previousCoordinate = self.previousCoordinate {
            var points: [CLLocationCoordinate2D] = []
            let point1 = CLLocationCoordinate2DMake(previousCoordinate.latitude, previousCoordinate.longitude)
            let point2: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            points.append(point1)
            points.append(point2)
            let lineDraw = MKPolyline(coordinates: points, count: points.count)
            mapView.addOverlay(lineDraw)
        }

        previousCoordinate = location.coordinate

        // 현재 속도를 알려줌
        let speed = location.speed
        let speedInMS = max(speed, 0)
        let speedInKmH = (round(max(speed * 3.6, 0) * 10)) / 10 // speed가 음수면 잘못된 speed이다.

        currentSpeed.send(speedInKmH)
        print("M/S speed: \(speedInMS)")
        print("KM/H Speed: \(speedInKmH)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.setUserTrackingMode(.follow, animated: true)
            startTracking()
        case .restricted, .denied:
            showLocationDisabledAlert()
        case .notDetermined:
            getLocationUsagePermission()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get the location due to \(error.localizedDescription)")
    }
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let polyLine = overlay as? MKPolyline else {
            print("can't draw polyline")
            return MKOverlayRenderer()
        }
        let renderer = MKPolylineRenderer(polyline: polyLine)
        renderer.strokeColor = .blue
        renderer.lineWidth = 8.0
        renderer.alpha = 1.0

        return renderer
    }
}

///Feat: 자동시작, 자동 멈춤
///
///
