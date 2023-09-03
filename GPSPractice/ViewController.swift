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
    var totalSpeeds: [Double] = []
    @IBOutlet weak var speedLabel: UILabel!

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var averageSpeedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        getLocationUsagePermission()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.delegate = self
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.locationManager.stopUpdatingLocation()
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
        DispatchQueue.main.async { [self] in
            self.speedLabel.text = "\(Int(speedInKmH))"
            if speedInKmH > 0 {
                self.totalSpeeds.append(speedInKmH)
            }
            if totalSpeeds.count > 0 {
                self.averageSpeedLabel.text = "\(Int(totalSpeeds.reduce(0, +)) / totalSpeeds.count)"
            }
        }
        previousCoordinate = location.coordinate
    }

    func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("GPS 권한 설정됨")
        case .restricted, .notDetermined:
            print("GPS 권한 설정되지 않음")
            DispatchQueue.main.async { [weak self] in
                self?.getLocationUsagePermission()
            }
        case .denied:
            print("GPS 권한 요청 거부됨")
            DispatchQueue.main.async { [weak self] in
                self?.getLocationUsagePermission()
            }
        default:
            print("GPS: Default")
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
        renderer.strokeColor = .orange
        renderer.lineWidth = 5.0
        renderer.alpha = 1.0

        return renderer
    }
}
