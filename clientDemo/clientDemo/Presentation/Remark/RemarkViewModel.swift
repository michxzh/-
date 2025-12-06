//
//  RemarkViewModel.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import Foundation
import Combine 

final class RemarkViewModel: ObservableObject {
    @Published var remarkText: String

    let message: Message
    private let repository: MessageRepositoryType

    init(message: Message,
         repository: MessageRepositoryType = MessageRepository()) {
        AnalyticsManager.shared.trackOpenRemark(message)
        self.message = message
        self.repository = repository

        // 从 SQLite 再读一遍，保证最新
        if let state = repository.loadState(for: message.id), let remark = state.remark {
            self.remarkText = remark
        } else {
            self.remarkText = message.remark ?? ""
        }
    }

    func saveRemark() {
        var updated = message
        updated.remark = remarkText.isEmpty ? nil : remarkText
        repository.updateState(for: updated)
    }
}
