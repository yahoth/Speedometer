//
//  SavedResult+CoreDataClass.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/13.
//
//

import Foundation
import CoreData

@objc(SavedResult)
public class SavedResult: NSManagedObject {
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
