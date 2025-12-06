//
//  Message.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//
import Foundation
struct Message: Identifiable, Codable {
    let id: String
    let type: MessageType
    let avatar: String
    let nickname: String

    /// 列表里的摘要
    let summary: String

    /// 内容类型（不写进 JSON 时默认为 .text）
    var contentType: MessageContentType?

    /// 图片类消息用的本地图片名
    var imageName: String?

    /// 运营类消息按钮标题，比如“领取奖励”
    var actionTitle: String?
    var isPinned: Bool?

    /// 我们改成时间戳，方便套你那套规则
    let createdAt: Date?

    /// 旧字段，后面会用 formatter 算出来再展示
    var timeText: String {
        TimeFormatter.shared.format(date: createdAt ?? Date())
    }

    var unreadCount: Int
    var remark: String?
}
