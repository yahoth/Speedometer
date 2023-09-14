//
//  DateFormatters.swift
//  Speedometer
//
//  Created by TAEHYOUNG KIM on 2023/09/14.
//

import Foundation

class DateFormatters {
    static let shared = DateFormatters()

    private let monthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일"
        return formatter
    }()

    private let fullDateTime: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "M월 d일 a h시 m분"
        return formatter
    }()

    private let timeOnly: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "a h시 m분"
        return formatter
    }()

    func stringMonthDay(from date: Date) -> String {
        return monthDay.string(from: date)
    }

    func stringFullDateTime(from date: Date) -> String {
        return fullDateTime.string(from: date)
    }

    func stringTimeOnly(from date: Date) -> String {
        return timeOnly.string(from: date)
    }

}
