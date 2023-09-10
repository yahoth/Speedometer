//
//  SpeedometerViewModel.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import Foundation
import CoreLocation
import MapKit
import Combine

final class SpeedometerViewModel {
    let locationPublisher = LocationPublisher()
    let stopwatch = Stopwatch()
    var previousCoordinate: CLLocationCoordinate2D?
    var previousLocation: CLLocation?
    @Published var logsOfSpeed: [Double] = []
    @Published var topSpeed: Double = 0
    @Published var totalDistance: CLLocationDistance = 0
    let currentSpeed = CurrentValueSubject<CLLocationSpeed, Never>(0)
    @Published var averageSpeed: Double = 0
    @Published var alititude: Double = 0
    @Published var allCoordinates: [CLLocationCoordinate2D] = []
    @Published var span: MKCoordinateSpan?
    @Published var speedometerResult: SpeedmeterResult?
    var subscriptions = Set<AnyCancellable>()

    init() {
        bind()
    }

    func  createSpeedometerResult() {
        let result = SpeedmeterResult(duration: stopwatch.totalElapsedTime, distance: totalDistance, averageSpeed: averageSpeed, topSpeed: topSpeed, altitude: alititude)
        speedometerResult = result
    }

    private func bind() {
        locationPublisher.$currentLocation
            .compactMap { $0 }
            .sink { location in
                let speed = location.speed
                let speedInKilometersPerHour = max(speed * 3.6, 0)
                self.currentSpeed.send(round(speedInKilometersPerHour * 10) / 10)
                self.logsOfSpeed.append(speedInKilometersPerHour)

                // 움직임이 있을 경우만 location update
                if speed > 0 {
                    self.allCoordinates.append(location.coordinate)

                    guard let previousLocation = self.previousLocation else { return }
                    let distance = location.distance(from: previousLocation)
                    self.totalDistance += distance

                    if location.altitude > previousLocation.altitude {
                        self.alititude += round(location.altitude - previousLocation.altitude)
                    }

                    self.previousLocation = location
                }
            }.store(in: &subscriptions)

        $logsOfSpeed
            .receive(on: DispatchQueue.global())
            .sink { logs in
                // Average Speed
                let count = Double(logs.count)
                let sumOfLogs = logs.reduce(0, +)
                let averageSpeed = round(sumOfLogs / count * 10) / 10

                self.averageSpeed = averageSpeed

                // Top Speed
                guard let topSpeed = logs.max() else { return }
                self.topSpeed = round(topSpeed * 10) / 10
            }.store(in: &subscriptions)
    }

    func startTracking() {
        locationPublisher.startUpdatingLocation()
        stopwatch.start()
    }

    func pauseTracking() {
        locationPublisher.stopUpdatingLocation()
        stopwatch.pause()

    }

    func stopTracking() {
        locationPublisher.stopUpdatingLocation()
        stopwatch.stop()
    }
}
