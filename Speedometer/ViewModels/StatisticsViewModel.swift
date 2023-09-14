//
//  StatisticsViewModel.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/14.
//

import Foundation
import Combine

class StatisticsViewModel {
    let coredataManager = CoreDataManager()

    @Published var results: [SavedResult]?

    func fetch() {
        results = coredataManager.fetchResults()
    }
}
