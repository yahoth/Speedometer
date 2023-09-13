//
//  SpeedmeterResult.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/10.
//

import UIKit

struct SpeedmeterResult: Hashable {
    var duration: Int
    var distance: Double
    var averageSpeed: Double
    var topSpeed: Double
    var altitude: Double
    var title: String?
    var mapView: UIImage?
    var image: UIImage?

    var distanceString: String {
        switch distance {
        case 0..<1000:
             return "\(Int(round(distance)))M"
        case 1000...:
            return "\((round(distance / 10) / 100))KM"
        default:
            return "0"
        }
    }

    var averageSpeedString: String {
        averageSpeed.isNaN ? "0KM/H" : "\(averageSpeed)KM/H"
    }
    
    var durationString: String {
        let hours = duration / 3600
        let minutes = (duration % 3600) / 60
        let seconds = (duration % 3600) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var altitudeString: String {
        "\(Int(round(altitude)))M"
    }
}
