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
    @Published private (set) var authorizationStatus: CLAuthorizationStatus

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
}
