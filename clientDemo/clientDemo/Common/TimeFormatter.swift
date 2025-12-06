//
//  TimeFormatter.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation

final class TimeFormatter {
    static let shared = TimeFormatter()
    private let calendar = Calendar.current

    private init() {}

    func format(date: Date) -> String {
        let now = Date()
        let seconds = Int(now.timeIntervalSince(date))

        if seconds < 60 {
            return "刚刚"
        }

        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes) 分钟前"
        }

        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }

        if calendar.isDateInYesterday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return "昨天 " + formatter.string(from: date)
        }

        if let days = calendar.dateComponents([.day], from: date, to: now).day, days < 7 {
            return "\(days) 天前"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        return formatter.string(from: date)
    }
}
