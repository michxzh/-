//
//  MessageRowWrapper.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import SwiftUI

struct MessageRowWrapper: View {
    let message: Message
    let searchQuery: String
    let viewModel: MessageListViewModel

    @Environment(\.displayScale) private var displayScale
    @State private var isPressed = false

    var body: some View {
        Button {
            // 点击进入备注弹窗
            AnalyticsManager.shared.trackOpenMessage(message)
            viewModel.selectedMessage = message
            viewModel.markAsRead(message)
        } label: {
            MessageRowView(message: message, searchQuery: searchQuery)
                .contentShape(Rectangle())
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.01, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        }, perform: {})
        
        .swipeActions(edge: .trailing) {
            Button {
                viewModel.togglePin(message)
            } label: {
                Label(message.isPinned == true ? "取消置顶" : "置顶",
                      systemImage: "pin.fill")
            }
            .tint(.yellow)
        }
    }
}
