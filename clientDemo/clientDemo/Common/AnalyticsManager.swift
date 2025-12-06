//
//  AnalyticsManager.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation

final class AnalyticsManager {

    static let shared = AnalyticsManager()
    private let store = AnalyticsStore()

    private init() {}

    // 记录消息到来（insertMockMessage）
    func trackNewMessage(_ msg: Message) {
        let event = AnalyticsEvent(
            eventId: UUID().uuidString,
            eventType: "new_message",
            messageId: msg.id,
            messageType: msg.contentType?.rawValue,
            timestamp: Date().timeIntervalSince1970
        )
        store.insert(event: event)
    }

    // 记录点击打开消息
    func trackOpenMessage(_ msg: Message) {
        let event = AnalyticsEvent(
            eventId: UUID().uuidString,
            eventType: "open_message",
            messageId: msg.id,
            messageType: msg.contentType?.rawValue,
            timestamp: Date().timeIntervalSince1970
        )
        store.insert(event: event)
    }

    // 记录打开备注页
    func trackOpenRemark(_ msg: Message) {
        let event = AnalyticsEvent(
            eventId: UUID().uuidString,
            eventType: "open_remark",
            messageId: msg.id,
            messageType: msg.contentType?.rawValue,
            timestamp: Date().timeIntervalSince1970
        )
        store.insert(event: event)
    }
}
