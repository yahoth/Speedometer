//
//  Stopwatch.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/06.
//

import Foundation
import Combine

class Stopwatch {
    private var timer: AnyCancellable?
    private var startDate: Date?
    private var elapsedTimeWhenPaused: TimeInterval = 0
    @Published var totalElapsedTime: Int = 0

    func start() {
        startDate = Date()
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                if let startDate = self?.startDate {
                    let totalElapsedTime = Int(Date().timeIntervalSince(startDate) + self!.elapsedTimeWhenPaused)
                    self?.totalElapsedTime = totalElapsedTime
                }
            }
        print("Stopwatch start.")
    }

    func pause() {
        if let startDate = startDate {
            elapsedTimeWhenPaused += Date().timeIntervalSince(startDate)
        }
        timer?.cancel()
        timer = nil

        print("Stopwatch paused.")
    }

    func stop() {
        timer?.cancel()
        timer = nil

        print("Stopwatch stopped")
    }
}
