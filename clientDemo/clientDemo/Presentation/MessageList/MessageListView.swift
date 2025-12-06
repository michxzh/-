//
//  MessageListView.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//


import SwiftUI

struct MessageListView: View {

    @StateObject private var viewModel = MessageListViewModel()
    @State private var searchText: String = ""
    @Namespace private var cardNamespace

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    SkeletonListView()      
                } else if viewModel.isError {
                    ErrorStateView(message: viewModel.errorMessage) {
                        viewModel.loadInitial()
                    }
                } else if viewModel.isEmpty {
                    EmptyStateView(title: "暂无消息", subtitle: "下拉刷新试试")
                } else {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(filteredMessages) { msg in
                                MessageRowWrapper(message: msg,
                                                  searchQuery: searchText,
                                                  viewModel: viewModel)
                                    .id(msg.id)
                                    .onAppear {
                                        viewModel.loadMoreIfNeeded(currentItem: msg)
                                    }
                            }

                            if viewModel.canLoadMore {
                                HStack {
                                    Spacer()
                                    ProgressView()
                                    Spacer()
                                }
                            }
                        }
                        .listStyle(.plain)
                        .refreshable {
                            viewModel.refresh()
                        }
                        .onChange(of: viewModel.lastInsertedMessageId) { newId in
                            guard let newId else { return }
                            withAnimation {
                                proxy.scrollTo(newId, anchor: .top)
                            }
                        }
                    }
                }
            }
            .navigationTitle("消息")
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: "搜索昵称或内容")
        }
        .overlay(
            Group {
                if let message = viewModel.selectedMessage {
                    RemarkDetailContainer(
                        message: message,
                        namespace: cardNamespace,
                        onClose: {
                            viewModel.selectedMessage = nil
                        },
                        onSaveRemark: { remark in
                            viewModel.updateRemark(for: message.id, remark: remark)
                        }
                    )
                    .transition(.opacity.combined(with: .scale))
                    .zIndex(10)
                }
            }
        )
        .animation(.spring(), value: viewModel.selectedMessage?.id)
        .onAppear {
            viewModel.loadInitial()
        }
    }

    private var filteredMessages: [Message] {
        guard !searchText.isEmpty else { return viewModel.messages }
        return viewModel.messages.filter {
            $0.nickname.localizedCaseInsensitiveContains(searchText) ||
            $0.summary.localizedCaseInsensitiveContains(searchText)
        }
    }
}
