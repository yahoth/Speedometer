//
//  LocationPublisher.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/06.
//

import Foundation
import CoreLocation
import Combine

class LocationPublisher: NSObject, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager

    @Published private(set) var currentLocation: CLLocation?
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        self.authorizationStatus = locationManager.authorizationStatus

        super.init()

        setUp()
    }

    private func setUp() {
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        self.authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations.last
    }

    func reverseGeocodeLocation(_ startCoordinate: CLLocationCoordinate2D, _ endCoordinate: CLLocationCoordinate2D) async -> (String, String) {
        let geocoder = CLGeocoder()

        let startLocation = CLLocation(latitude: startCoordinate.latitude, longitude: startCoordinate.longitude)
        let endLocation = CLLocation(latitude: endCoordinate.latitude, longitude: endCoordinate.longitude)
        let errorResult = ("위치정보 미상", "")

        do {
            guard let startPlacemark = try await geocoder.reverseGeocodeLocation(startLocation).first else { return errorResult }
            guard let endPlacemark = try await geocoder.reverseGeocodeLocation(endLocation).first else { return errorResult }

            let start = "\(startPlacemark.locality ?? "") \(startPlacemark.subLocality ?? "")"
            let end = "\(endPlacemark.locality ?? "") \(endPlacemark.subLocality ?? "")"
            return (start, end)
        } catch let error {
            print(error.localizedDescription)
            return errorResult
        }
    }

//    func getPlaceMark(for coordinate: CLLocationCoordinate2D) -> Future<CLPlacemark, Error> {
//
//        let geocoder = CLGeocoder()
//        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//
//        return Future() { promise in
//            geocoder.reverseGeocodeLocation(location) { placemarks, error in
//                if let error = error {
//                    promise(.failure(error))
//                    return
//                }
//                guard let placemark = placemarks?.first else {
//                    promise(.failure(CLError(.geocodeFoundNoResult)))
//                    return
//                }
//
//                promise(.success(placemark))
//            }
//        }
//    }
}
