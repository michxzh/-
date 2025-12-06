//
//  AnalyticsStore.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation
import SQLite3

final class AnalyticsStore {

    private let db: OpaquePointer?

    init(db: OpaquePointer? = SQLiteManager.shared.getDB()) {
        self.db = db
    }

    // Insert Event
    func insert(event: AnalyticsEvent) {
        let sql = """
        INSERT INTO analytics_event (eventId, eventType, messageId, messageType, timestamp)
        VALUES (?, ?, ?, ?, ?);
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }

        sqlite3_bind_text(stmt, 1, (event.eventId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (event.eventType as NSString).utf8String, -1, nil)

        if let msgId = event.messageId {
            sqlite3_bind_text(stmt, 3, (msgId as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 3)
        }

        if let msgType = event.messageType {
            sqlite3_bind_text(stmt, 4, (msgType as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 4)
        }

        sqlite3_bind_double(stmt, 5, event.timestamp)

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ Failed to insert analytics event")
        }

        sqlite3_finalize(stmt)
    }

    // Load All Events
    func loadAllEvents() -> [AnalyticsEvent] {
        var events: [AnalyticsEvent] = []

        let sql = "SELECT eventId, eventType, messageId, messageType, timestamp FROM analytics_event;"
        var stmt: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return events }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = String(cString: sqlite3_column_text(stmt, 0))
            let type = String(cString: sqlite3_column_text(stmt, 1))

            let msgId = sqlite3_column_text(stmt, 2).flatMap { String(cString: $0) }
            let msgType = sqlite3_column_text(stmt, 3).flatMap { String(cString: $0) }

            let ts = sqlite3_column_double(stmt, 4)

            events.append(AnalyticsEvent(
                eventId: id,
                eventType: type,
                messageId: msgId,
                messageType: msgType,
                timestamp: ts
            ))
        }

        sqlite3_finalize(stmt)
        return events
    }
}


// Analytics Methods (CTR, Trend, Today Count)
extension AnalyticsStore {

    // 今日新增消息数（new_message）
    func countTodayMessages() -> Int {
        let start = Calendar.current.startOfDay(for: Date()).timeIntervalSince1970

        let sql = """
        SELECT COUNT(*) FROM analytics_event
        WHERE eventType = 'new_message'
        AND timestamp >= ?;
        """

        var stmt: OpaquePointer?
        var result = 0

        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }

        sqlite3_bind_double(stmt, 1, start)

        if sqlite3_step(stmt) == SQLITE_ROW {
            result = Int(sqlite3_column_int(stmt, 0))
        }

        sqlite3_finalize(stmt)
        return result
    }

    // 最近 7 天未读趋势（按日统计 new_message）
    func unreadTrend(lastDays: Int = 7) -> [(String, Int)] {
        var result: [(String, Int)] = []
        let cal = Calendar.current

        for i in (0..<lastDays).reversed() {
            guard let day = cal.date(byAdding: .day, value: -i, to: Date()) else { continue }

            let start = cal.startOfDay(for: day).timeIntervalSince1970
            let end = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: day))!.timeIntervalSince1970

            let sql = """
            SELECT COUNT(*) FROM analytics_event
            WHERE eventType = 'new_message'
            AND timestamp >= ? AND timestamp < ?;
            """

            var stmt: OpaquePointer?
            var count = 0

            if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
                sqlite3_bind_double(stmt, 1, start)
                sqlite3_bind_double(stmt, 2, end)

                if sqlite3_step(stmt) == SQLITE_ROW {
                    count = Int(sqlite3_column_int(stmt, 0))
                }
            }

            sqlite3_finalize(stmt)

            let label = DateFormatter.localizedString(from: day, dateStyle: .short, timeStyle: .none)
            result.append((label, count))
        }

        return result
    }

    // CTR 统计（open_message / new_message 按 messageType）
    func messageCTRByType() -> [(String, Double)] {
        let sql = """
        SELECT messageType,
            SUM(CASE WHEN eventType = 'open_message' THEN 1 ELSE 0 END) AS openCount,
            SUM(CASE WHEN eventType = 'new_message' THEN 1 ELSE 0 END) AS arrivalCount
        FROM analytics_event
        GROUP BY messageType;
        """

        var stmt: OpaquePointer?
        var list: [(String, Double)] = []

        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return list }

        while sqlite3_step(stmt) == SQLITE_ROW {

            let msgType = sqlite3_column_text(stmt, 0).flatMap { String(cString: $0) } ?? "unknown"

            let openCount = Double(sqlite3_column_int(stmt, 1))
            let arrivalCount = Double(sqlite3_column_int(stmt, 2))

            let ctr = arrivalCount > 0 ? openCount / arrivalCount : 0

            list.append((msgType, ctr))
        }

        sqlite3_finalize(stmt)
        return list
    }
}
