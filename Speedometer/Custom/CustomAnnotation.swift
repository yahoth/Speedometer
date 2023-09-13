//
//  CustomAnnotation.swift
//  GPSPractice
//
//  Created by TAEHYOUNG KIM on 2023/09/07.
//

import Foundation
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var isStartPoint: Bool

    init(coordinate: CLLocationCoordinate2D, isStartPoint: Bool) {
        self.coordinate = coordinate
        self.isStartPoint = isStartPoint
    }
}
