//
//  ViewController.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/03.
//

import UIKit
import CoreLocation
import MapKit
import RealmSwift

class ViewController: UIViewController {
    var locationManager: CLLocationManager!
    var previousCoordinate: CLLocationCoordinate2D?
    var totalSpeeds: [Double]!

    @IBOutlet weak var speedLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var averageSpeedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        mapView.showsUserLocation = true
        setUserTrackingMode()
        mapView.delegate = self
        totalSpeeds = []
    }

    //현재 위치로 이동
    @IBAction func locationButton(_ sender: Any) {
        setUserTrackingMode()
    }

    private func setUserTrackingMode() {
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            mapView.setUserTrackingMode(.follow, animated: true)
        }
    }

    func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func showLocationDisabledAlert() {
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

        let speed = location.speed
        let speedInKmH = max(speed * 3.6, 0)

        print(speedInKmH)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.speedLabel.text = "\(Int(speedInKmH))"
            if speedInKmH > 0 {
                self.totalSpeeds.append(speedInKmH)
            }
            if self.totalSpeeds.count > 0 {
                self.averageSpeedLabel.text = "\(Int(self.totalSpeeds.reduce(0, +)) / self.totalSpeeds.count)"
            }
        }
        previousCoordinate = location.coordinate
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            mapView.setUserTrackingMode(.follow, animated: true)
            break

        case .restricted, .denied:
            showLocationDisabledAlert()

        case .notDetermined:
            getLocationUsagePermission()
            break

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

/// FIX: 현재 속도는 그럭저럭 비슷하게 나온다.
/// 하지만 평균 속도를 구하는 방법이 잘못됐다.
/// 현재는, 0이상의 count되는 속도만 count수로 나눈다.
/// 해결책1:
/// didUpdateLocation이 움직임을 측정해서 count가 시작이 되면,
/// 타이머를 가동하여 1초마다 측정된 속도를 집계해서 배열에 넣는다.
/// 시작이 된 시간을 집계해서 속도를 다 더하고 나눈다.
///

