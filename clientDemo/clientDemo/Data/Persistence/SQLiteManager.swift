//
//  SQLiteManager.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation
import SQLite3

final class SQLiteManager {

    static let shared = SQLiteManager()

    private var db: OpaquePointer?

    private init() {
        openDatabase()
        createTablesIfNeeded()
    }

    // 打开数据库
    private func openDatabase() {
        let fileManager = FileManager.default
        let docsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbUrl = docsUrl.appendingPathComponent("messages.sqlite")

        if sqlite3_open(dbUrl.path, &db) != SQLITE_OK {
            print("❌ Failed to open database")
        } else {
            print("✅ Database opened at: \(dbUrl.path)")
        }
    }

    // 创建所有表（message_state + analytics_event）
    private func createTablesIfNeeded() {

        // --------------------------
        // 1. message_state 表
        // --------------------------
        let sql = """
        CREATE TABLE IF NOT EXISTS message_state (
            messageId TEXT PRIMARY KEY,
            unreadCount INTEGER NOT NULL,
            remark TEXT,
            isPinned INTEGER NOT NULL DEFAULT 0
        );
        """

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
            print("✅ message_state table ensured")
        }
        sqlite3_finalize(stmt)

        // --------------------------
        // 2. analytics_event 表
        // --------------------------
        createAnalyticsTable()

        // --------------------------
        // 3. schema 升级：检查是否缺少 isPinned
        // --------------------------
        migrateIfNeeded()
    }

    // 创建 analytics_event 表
    private func createAnalyticsTable() {
        let sql = """
        CREATE TABLE IF NOT EXISTS analytics_event (
            eventId TEXT PRIMARY KEY,
            eventType TEXT NOT NULL,
            messageId TEXT,
            messageType TEXT,
            timestamp REAL NOT NULL
        );
        """

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_step(stmt)
            print("✅ analytics_event table ensured")
        } else {
            print("❌ Failed to create analytics_event table")
        }
        sqlite3_finalize(stmt)
    }

    // Schema Migration
    private func migrateIfNeeded() {
        guard let db = db else { return }

        // 检查 isPinned 是否存在
        let pragmaSQL = "PRAGMA table_info(message_state);"
        var stmt: OpaquePointer?
        var hasIsPinned = false

        if sqlite3_prepare_v2(db, pragmaSQL, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let cName = sqlite3_column_text(stmt, 1) {
                    if String(cString: cName) == "isPinned" {
                        hasIsPinned = true
                        break
                    }
                }
            }
        }
        sqlite3_finalize(stmt)

        // 如果没有 isPinned → 补充 migration
        if !hasIsPinned {
            let alterSQL = "ALTER TABLE message_state ADD COLUMN isPinned INTEGER NOT NULL DEFAULT 0;"
            var alterStmt: OpaquePointer?
            if sqlite3_prepare_v2(db, alterSQL, -1, &alterStmt, nil) == SQLITE_OK {
                sqlite3_step(alterStmt)
                print("✅ Migration: added isPinned column")
            }
            sqlite3_finalize(alterStmt)
        }
    }

    // MARK: - Database getter
    func getDB() -> OpaquePointer? {
        return db
    }
}
