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

class ViewController: UIViewController {
    var locationManager: CLLocationManager!
    var previousCoordinate: CLLocationCoordinate2D?
    var previousLocation: CLLocation?
    @Published var logOfSpeed: [Double]!
    @Published var totalDistance: CLLocationDistance = 0
    let currentSpeed = CurrentValueSubject<CLLocationSpeed, Never>(0)
    var averageSpeed: Double = 0
    var tempTotalDistance: Double = 0
    var topSpeed: Double = 0
    var subscriptions = Set<AnyCancellable>()

    @IBOutlet weak var speedLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var totalDistanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UITextField!

    let stopwatch = Stopwatch()

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
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    private func bind() {
        currentSpeed
            .map { round($0 * 10) / 10 }
            .receive(on: RunLoop.main)
            .sink { [unowned self] speed in
                self.speedLabel.text = speed == 0.0 ? "0" : "\(speed)"
                logOfSpeed.append(speed)
                print("currentSpeed: \(speed)km/h")
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
                self.averageSpeedLabel.text = averageSpeed.isNaN ? "0" : "\(averageSpeed)"
                self.averageSpeed = averageSpeed
            }.store(in: &subscriptions)

        $totalDistance
            .receive(on: RunLoop.main)
            .sink { [unowned self] distance in
                switch distance {
                case 0..<1000:
                    self.totalDistanceLabel.text = "\(Int(round(distance)))M"
                case 1000...:
                    self.totalDistanceLabel.text = "\((round(distance / 10) / 100))KM"
                default:
                    break
                }
                self.tempTotalDistance = distance
            }.store(in: &subscriptions)
        
        stopwatch.$totalElapsedTime
            .receive(on: RunLoop.main)
            .sink { [unowned self] time in
                let hours = time / 3600
                let minutes = (time % 3600) / 60
                let seconds = (time % 3600) % 60

                self.timeLabel.text = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            }.store(in: &subscriptions)
    }

    private func trackingStart() {
    }

    private func stopTracking() {
        locationManager.stopUpdatingLocation()
        stopwatch.pause()
    }

    private func startTracking() {
        locationManager.startUpdatingLocation()
        stopwatch.start()
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

    @IBAction func finishButtonTapped(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        stopwatch.stop()
        let sb = UIStoryboard(name: "Result", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "ResultViewController") as! ResultViewController
        vc.averageSpeed = averageSpeed
        vc.totalDistance = tempTotalDistance
        present(vc, animated: true)
    }

    private func setUserTrackingMode() {
        if locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways {
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
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

        // 현재 이동 속도 기록
        let speed = location.speed
        let speedInMH = max(speed * 3.6, 0)
        currentSpeed.send(speedInMH)

        if speed > 0 {
            // 이동한 경로를 polyline으로 기록
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

            // 이동한 거리를 기록
            if let previousLocation = self.previousLocation {
                let distance = location.distance(from: previousLocation)
                self.totalDistance += distance
            }
            previousLocation = location
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
            break
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

        let green = UIColor(hex: "51E101")
        let yellow = UIColor(hex: "FFFF00")
        let orange = UIColor(hex: "FFA500")
        let red = UIColor(hex: "E00000")

        var rendererColor = green

        if self.currentSpeed.value >= 10 && self.currentSpeed.value <= 40 {
            // Calculate the percentage of current speed within the range [10, 40]
            let percentage = (self.currentSpeed.value - 10) / (40 - 10)

            if percentage < 0.5 {
                // Interpolate between green and yellow
                rendererColor = UIColor.interpolateColor(from: green, to: yellow, with: percentage * 2)
            } else {
                // Interpolate between yellow and orange
                rendererColor = UIColor.interpolateColor(from: yellow, to: orange, with:(percentage - 0.5) * 2)
            }
            // Set the stroke color of the renderer
            renderer.strokeColor = rendererColor
        } else if self.currentSpeed.value > 40 {
            // If speed is more than the maximum speed considered (40km/h), set the color to red.
            renderer.strokeColor = red
        } else{
            // If speed is less than the minimum speed considered (10km/h), set the color to green.
            renderer.strokeColor = green
        }
       renderer.lineWidth = 5.0
       renderer.alpha = 1.0
        return renderer
    }
}

