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
    let locationPublisher = LocationPublisher()
    var imagePickerDelegate = ImagePicker()

    @Published var speedometerResult: SavedResult
    @Published var span: MKCoordinateSpan?
    @Published var image: UIImage?
    @Published var mapView: UIImage?
    @Published var allCoordinates: [CLLocationCoordinate2D]
    @Published var startAndEndAddress: (String, String)?
    var subscriptions = Set<AnyCancellable>()

    var startCoordinate: CLLocationCoordinate2D {
        guard let coordinate = allCoordinates.first else { return CLLocationCoordinate2D()}
        return coordinate
    }

    var endCoordinate: CLLocationCoordinate2D {
        guard let coordinate = allCoordinates.last else { return CLLocationCoordinate2D()}
        return coordinate
    }

    init(speedometerResult: SavedResult, allCoordinates: [CLLocationCoordinate2D]) {
        self.speedometerResult = speedometerResult
        self.allCoordinates = allCoordinates

        Task {
            await reverseGeocodeLocation()
        }
        bind()
    }

    func bind() {
        imagePickerDelegate.selectedImagePublisher
            .receive(on: DispatchQueue.main)
            .sink { image in
                self.image = image
            }.store(in: &subscriptions)
    }

    func saveResult() {
        if let image {
            speedometerResult.image = image.pngData()
        }
        
        if let mapView {
            speedometerResult.mapView = mapView.pngData()
        }

        if let address = startAndEndAddress {
            speedometerResult.startAddress = address.0
            speedometerResult.endAddress = address.1
        }

        speedometerResult.mode = UserDefaults.standard.string(forKey: "Mode") ?? "cycling"

        speedometerResult.isCompleted = true
        coreDataManager.saveContext()
    }

    func reverseGeocodeLocation() async {
        startAndEndAddress = await locationPublisher.reverseGeocodeLocation(startCoordinate, endCoordinate)
    }
}
