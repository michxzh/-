//
//  MessageListViewModel.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//


import Foundation
import Combine

final class MessageListViewModel: ObservableObject {

    @Published var messages: [Message] = []
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var isError: Bool = false
    @Published var errorMessage: String = ""
    @Published var isEmpty: Bool = false
    @Published var canLoadMore: Bool = true
    @Published var lastInsertedMessageId: String?
    @Published var selectedMessage: Message?

    private let repository: MessageRepositoryType
    private var allMessages: [Message] = []
    private let pageSize: Int = 20
    private var currentPage: Int = 0
    private var timer: Timer?

    init(repository: MessageRepositoryType = MessageRepository()) {
        self.repository = repository
    }

    func loadInitial() {
        isLoading = true
        isError = false

        DispatchQueue.global().async {
            do {
                let all = try self.repository.loadInitialMessages()

                DispatchQueue.main.async {
                    self.allMessages = all
                    self.currentPage = 0
                    let firstPage = self.repository.loadPage(all: all, page: 0, pageSize: self.pageSize)

                    self.messages = firstPage
                    self.canLoadMore = firstPage.count == self.pageSize && firstPage.count < all.count
                    self.isEmpty = firstPage.isEmpty
                    self.isLoading = false

                    // 在成功加载后启动消息中心
                    self.startMockMessageCenter()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isError = true
                    self.errorMessage = error.localizedDescription
                    self.messages = []
                    self.isEmpty = true

                    
                }
            }
        }
    }

    func refresh() {
        isRefreshing = true
        isError = false
        DispatchQueue.global().async {
            do {
                let all = try self.repository.loadInitialMessages()
                DispatchQueue.main.async {
                    self.allMessages = all
                    self.currentPage = 0
                    let firstPage = self.repository.loadPage(all: all, page: 0, pageSize: self.pageSize)
                    self.messages = firstPage
                    self.canLoadMore = firstPage.count == self.pageSize && firstPage.count < all.count
                    self.isEmpty = firstPage.isEmpty
                    self.isRefreshing = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.isRefreshing = false
                    self.isError = true
                    self.errorMessage = error.localizedDescription
                    self.messages = []
                    self.isEmpty = true
                }
            }
        }
    }

    func loadMoreIfNeeded(currentItem item: Message?) {
        guard let item = item else { return }
        guard canLoadMore, !isLoading else { return }

        let thresholdIndex = messages.index(messages.endIndex, offsetBy: -1)
        if messages[thresholdIndex].id == item.id {
            loadMore()
        }
    }

    private func loadMore() {
        currentPage += 1
        let next = repository.loadPage(all: allMessages, page: currentPage, pageSize: pageSize)
        if next.isEmpty {
            canLoadMore = false
            return
        }
        messages.append(contentsOf: next)
        canLoadMore = next.count == pageSize && messages.count < allMessages.count
    }

    func markAsRead(_ message: Message) {
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
        var updated = messages[index]
        updated.unreadCount = 0
        messages[index] = updated

        // 同步到 allMessages & SQLite
        if let allIndex = allMessages.firstIndex(where: { $0.id == message.id }) {
            allMessages[allIndex] = updated
        }
        repository.updateState(for: updated)
    }

    func updateRemark(for messageId: String, remark: String?) {
        // 更新本地缓存
        if let index = messages.firstIndex(where: { $0.id == messageId }) {
            var m = messages[index]
            m.remark = remark
            messages[index] = m
            repository.updateState(for: m)
        }
        if let indexAll = allMessages.firstIndex(where: { $0.id == messageId }) {
            var m = allMessages[indexAll]
            m.remark = remark
            allMessages[indexAll] = m
        }
    }
    
    // 切换置顶状态
    func togglePin(_ message: Message) {
        // 1. 找到 messages 中的项
        guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }

        var updated = message
        updated.isPinned = !(message.isPinned ?? false)

        // 2. 写回 messages
        messages[index] = updated

        // 3. 同步 allMessages
        if let allIndex = allMessages.firstIndex(where: { $0.id == message.id }) {
            allMessages[allIndex] = updated
        }

        // 4. 写入 SQLite
        repository.updateState(for: updated)

        // 5. 立即重新排序，让置顶效果生效
        messages = sortMessages(messages)
    }
    
    func startMockMessageCenter() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            self?.insertMockMessage()
        }
    }
    
    private func sortMessages(_ list: [Message]) -> [Message] {
        list.sorted { a, b in
            let aPinned = a.isPinned ?? false
            let bPinned = b.isPinned ?? false

            // ① 先对比置顶
            if aPinned != bPinned {
                return aPinned && !bPinned
            }

            // ② 再按时间倒序
            return (a.createdAt ?? Date()) > (b.createdAt ?? Date())
        }
    }

    private func insertMockMessage() {
        let newId = UUID().uuidString

        let newMessage = Message(
            id: newId,
            type: MessageType.directMessage,
            avatar: "avatar1",
            nickname: "实时消息",
            summary: "这是本地消息中心模拟的一条新消息",
            contentType: MessageContentType.text,
            imageName: nil as String?,
            actionTitle: nil as String?,
            createdAt: Date(),
            unreadCount: 1,
            remark: nil as String?                    
        )
        AnalyticsManager.shared.trackNewMessage(newMessage)

        allMessages.insert(newMessage, at: 0)
        messages.insert(newMessage, at: 0)

        lastInsertedMessageId = newId
    }
    deinit {
            timer?.invalidate()
        }
}
