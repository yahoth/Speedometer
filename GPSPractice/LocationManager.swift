//
//  LocationManager.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/06.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    let locationManager: CLLocationManager

    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager

        super.init()

        setUp()
    }

    func setUp() {
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
    }

    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }

    func startTracking() {
        locationManager.startUpdatingLocation()
    }

    func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }


}
