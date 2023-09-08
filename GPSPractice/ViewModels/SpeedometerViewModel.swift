//
//  SpeedometerViewModel.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import Foundation
import CoreLocation
import Combine

final class SpeedometerViewModel {
    let locationPublisher = LocationPublisher()
    let stopwatch = Stopwatch()
    var previousCoordinate: CLLocationCoordinate2D?
    var previousLocation: CLLocation?
    @Published var logOfSpeed: [Double] = []

    var averageSpeedPublisher: AnyPublisher<Double, Never> {
        $logOfSpeed
        .subscribe(on: DispatchQueue.global())
        .map { logs -> Double in
            let count = Double(logs.count)
            let sumOfLogs = logs.reduce(0, +)
            let averageSpeed = round(sumOfLogs / count * 10) / 10

            return averageSpeed
        }.eraseToAnyPublisher()
    }

    var topSpeed: AnyPublisher<Double, Never> {
        $logOfSpeed
            .map { logs in
                guard let topSpeed = logs.max() else { return 0 }
                return round(topSpeed * 10) / 10
            }.eraseToAnyPublisher()
    }

    @Published var totalDistance: CLLocationDistance = 0
    let currentSpeed = CurrentValueSubject<CLLocationSpeed, Never>(0)
    var averageSpeed: Double = 0
    @Published var alititude: Double = 0
    var allCoordinates: [CLLocationCoordinate2D] = []
    var subscriptions = Set<AnyCancellable>()

    init() {
        bind()
    }

    private func bind() {
        locationPublisher.$currentLocation
            .compactMap { $0 }
            .sink { location in
                let speed = location.speed
                let speedInKilometersPerHour = max(speed * 3.6, 0)
                self.currentSpeed.send(speedInKilometersPerHour)
                self.logOfSpeed.append(speedInKilometersPerHour)

                // 움직임이 있을 경우만 location update
                if speed > 0 {
                    self.allCoordinates.append(location.coordinate)
                    if let previousLocation = self.previousLocation {
                        let distance = location.distance(from: previousLocation)
                        self.totalDistance += distance

                        if location.altitude > previousLocation.altitude {
                            self.alititude += location.altitude - previousLocation.altitude
                        }
                    }
                    self.previousLocation = location
                }
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
