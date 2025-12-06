//
//  MessageStateStore.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation
import SQLite3

struct MessageState {
    let messageId: String
    let unreadCount: Int
    let remark: String?
    let isPinned: Bool
}

final class MessageStateStore {

    private let db: OpaquePointer?

    init(db: OpaquePointer? = SQLiteManager.shared.getDB()) {
        self.db = db
    }

    // Load All States
    func loadAllStates() -> [String: MessageState] {
        var result: [String: MessageState] = [:]
        let sql = "SELECT messageId, unreadCount, remark, isPinned FROM message_state;"
        var stmt: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            return result
        }

        while sqlite3_step(stmt) == SQLITE_ROW {
            if let cStrId = sqlite3_column_text(stmt, 0) {

                let messageId = String(cString: cStrId)
                let unread = Int(sqlite3_column_int(stmt, 1))

                var remark: String? = nil
                if let cStrRemark = sqlite3_column_text(stmt, 2) {
                    remark = String(cString: cStrRemark)
                }

                let pinnedValue = sqlite3_column_int(stmt, 3)
                let isPinned = (pinnedValue == 1)

                result[messageId] = MessageState(
                    messageId: messageId,
                    unreadCount: unread,
                    remark: remark,
                    isPinned: isPinned
                )
            }
        }

        sqlite3_finalize(stmt)
        return result
    }

    // Save / Update State
    func saveState(
        messageId: String,
        unreadCount: Int,
        remark: String?,
        isPinned: Bool
    ) {
        let sql = """
        INSERT INTO message_state (messageId, unreadCount, remark, isPinned)
        VALUES (?, ?, ?, ?)
        ON CONFLICT(messageId) DO UPDATE SET
            unreadCount = excluded.unreadCount,
            remark = excluded.remark,
            isPinned = excluded.isPinned;
        """

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return }

        sqlite3_bind_text(stmt, 1, (messageId as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(unreadCount))

        if let remark = remark {
            sqlite3_bind_text(stmt, 3, (remark as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 3)
        }

        sqlite3_bind_int(stmt, 4, isPinned ? 1 : 0)

        if sqlite3_step(stmt) != SQLITE_DONE {
            print("❌ Failed to save state")
        }

        sqlite3_finalize(stmt)
    }

    // Get Single State
    func getState(for messageId: String) -> MessageState? {

        let sql = "SELECT messageId, unreadCount, remark, isPinned FROM message_state WHERE messageId = ?;"
        var stmt: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        sqlite3_bind_text(stmt, 1, (messageId as NSString).utf8String, -1, nil)

        defer { sqlite3_finalize(stmt) }

        if sqlite3_step(stmt) == SQLITE_ROW {

            if let cStrId = sqlite3_column_text(stmt, 0) {
                let id = String(cString: cStrId)
                let unread = Int(sqlite3_column_int(stmt, 1))

                var remark: String? = nil
                if let cStrRemark = sqlite3_column_text(stmt, 2) {
                    remark = String(cString: cStrRemark)
                }

                let pinnedValue = sqlite3_column_int(stmt, 3)
                let isPinned = (pinnedValue == 1)

                return MessageState(
                    messageId: id,
                    unreadCount: unread,
                    remark: remark,
                    isPinned: isPinned
                )
            }
        }

        return nil
    }
}
