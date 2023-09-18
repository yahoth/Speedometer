//
//  StatisticsDetailViewModel.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/18.
//

import Foundation
import Combine

class StatisticsDetailViewModel {
    @Published var result: SavedResult

    init(result: SavedResult) {
        self.result = result
    }
}
