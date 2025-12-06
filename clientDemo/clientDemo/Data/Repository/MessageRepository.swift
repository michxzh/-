//
//  MessageRepository.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation

protocol MessageRepositoryType {
    func loadInitialMessages() throws -> [Message]
    func applyStates(_ messages: [Message]) -> [Message]
    func loadPage(all messages: [Message], page: Int, pageSize: Int) -> [Message]
    func updateState(for message: Message)
    func loadState(for messageId: String) -> MessageState?
}

final class MessageRepository: MessageRepositoryType {

    private let stateStore: MessageStateStore

    init(stateStore: MessageStateStore = MessageStateStore()) {
        self.stateStore = stateStore
    }

    // 从 JSON 加载所有原始消息
    func loadInitialMessages() throws -> [Message] {
        guard let url = Bundle.main.url(forResource: "messages", withExtension: "json") else {
            throw NSError(domain: "MessageRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "messages.json not found"])
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let messages = try decoder.decode([Message].self, from: data)
        return applyStates(messages)
    }

    // 把 SQLite 中的状态合并到消息列表
    func applyStates(_ messages: [Message]) -> [Message] {
        let states = stateStore.loadAllStates()

        return messages.map { msg in
            if let state = states[msg.id] {
                var newMsg = msg
                newMsg.unreadCount = state.unreadCount
                newMsg.remark = state.remark
                newMsg.isPinned = state.isPinned   // ⭐ 加入 isPinned
                return newMsg
            } else {
                return msg
            }
        }
    }

    // 模拟分页
    func loadPage(all messages: [Message], page: Int, pageSize: Int) -> [Message] {
        let start = page * pageSize
        let end = min(start + pageSize, messages.count)
        if start >= end { return [] }
        return Array(messages[start..<end])
    }

    // 保存消息状态到 SQLite
    func updateState(for message: Message) {
        stateStore.saveState(
            messageId: message.id,
            unreadCount: message.unreadCount,
            remark: message.remark,
            isPinned: message.isPinned ?? false   // ⭐ 保存 isPinned，默认 false
        )
    }

    // 从 SQLite 读取状态
    func loadState(for messageId: String) -> MessageState? {
        stateStore.getState(for: messageId)
    }
}
