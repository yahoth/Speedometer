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
import CoreData

//ToDo - ViewModel 분리하기: 디테일뷰로 가면 돌아오지 않으니, 데이터를 넘겨주고 deinit이 나을 것으로 예상됨. - 성능

final class SpeedometerViewModel {
    let locationPublisher = LocationPublisher()
    let coredataManager = CoreDataManager()
    let stopwatch = Stopwatch()
    var previousLocation: CLLocation?
    var startDate: Date?
    var endDate: Date?
    @Published var logsOfSpeed: [Double] = []
    @Published var topSpeed: Double = 0
    @Published var totalDistance: CLLocationDistance = 0
    let currentSpeed = CurrentValueSubject<CLLocationSpeed, Never>(0)
    @Published var averageSpeed: Double = 0
    @Published var alititude: Double = 0
    @Published var allCoordinates: [CLLocationCoordinate2D] = []
    @Published var span: MKCoordinateSpan?
    @Published var speedometerResult: SpeedmeterResult?
    @Published var image: UIImage?
    var subscriptions = Set<AnyCancellable>()

    init() {
        bind()
    }

    func createSpeedometerResult() {
        guard let startDate else { return }
        let result = SpeedmeterResult(startDate: startDate, endDate: Date(), time: stopwatch.totalElapsedTime, distance: totalDistance, averageSpeed: averageSpeed, topSpeed: topSpeed, altitude: alititude)
        speedometerResult = result
    }

    func saveResult() {
        speedometerResult?.image = image
        guard let speedometerResult else { return }
        coredataManager.createResult(result: speedometerResult)
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

                    if let previousLocation = self.previousLocation {
                        let distance = location.distance(from: previousLocation)
                        print("distance: \(distance)")
                        self.totalDistance += distance
                        
                        if location.altitude > previousLocation.altitude {
                            self.alititude += location.altitude - previousLocation.altitude
                        }
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
