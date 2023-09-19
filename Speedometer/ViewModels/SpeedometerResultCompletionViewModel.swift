//
//  SpeedometerResultCompletionViewModel.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/18.
//

import Foundation
import Combine
import MapKit

class SpeedometerResultCompletionViewModel {
    let coreDataManager = CoreDataManager()
    @Published var speedometerResult: SavedResult
    @Published var span: MKCoordinateSpan?
    @Published var image: UIImage?
    @Published var allCoordinates: [CLLocationCoordinate2D]

    init(speedometerResult: SavedResult, allCoordinates: [CLLocationCoordinate2D]) {
        self.speedometerResult = speedometerResult
        self.allCoordinates = allCoordinates
    }

    func saveResult() {
        if let image {
            speedometerResult.image = image.pngData()
        }
        speedometerResult.isCompleted = true
        coreDataManager.saveContext()
    }
}
