//
//  SpeedmeterResult.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/10.
//

import UIKit

struct SpeedmeterResult: Hashable {
    let startDate: Date
    let endDate: Date
    let time: Int
    let distance: Double
    let averageSpeed: Double
    let topSpeed: Double
    let altitude: Double
    var title: String?
    var mapView: UIImage?
    var image: UIImage?
}

extension SpeedmeterResult {
    var distanceString: String {
        switch distance {
        case 0..<1000: // 1KM 미만일 때 Meter 단위
             return "\(Int(round(distance)))M"
        case 1000...: // 1KM 이상일 때 KM 단위
            return "\((round(distance / 10) / 100))KM"
        default:
            return "0"
        }
    }

    var averageSpeedString: String {
        averageSpeed.isNaN ? "0KM/H" : "\(averageSpeed)KM/H"
    }

    var timeString: String {
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = (time % 3600) % 60

        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var altitudeString: String {
        "\(Int(round(altitude)))M"
    }

    var duration: String {
        // 시작과 끝이 같은 날이면 ex) 9월 1일 오전 0시 0분 ~ 오후 1시 20분
        // 날짜가 바뀌면 ex) 9월 1일 오전 0시 0분 ~ 9월 2일 오전 0시 0분
        "\(DateFormatters.shared.stringFullDateTime(from: startDate)) ~ \(isSameDay ? DateFormatters.shared.stringTimeOnly(from: endDate) : DateFormatters.shared.stringFullDateTime(from: endDate))"
    }

    var defaultTitle: String {
        "\(DateFormatters.shared.stringMonthDay(from: startDate))의 기록"
    }

    var isSameDay: Bool {
        Calendar.current.isDate(startDate, inSameDayAs: endDate)
    }
}
