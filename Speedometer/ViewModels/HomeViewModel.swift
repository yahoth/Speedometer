//
//  HomeViewModel.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/18.
//

import Foundation

class HomeViewModel {
    let locationPublisher = LocationPublisher()
    @Published var mode: Mode
    let defaults = UserDefaults.standard

    init() {
        let modeValue = defaults.string(forKey: "Mode") ?? "cycling"
        self.mode = Mode(rawValue: modeValue) ?? .cycling
    }

    func updateMode(_ mode: Mode) {
        self.mode = mode
        defaults.set(mode.rawValue, forKey: "Mode")
    }
}
