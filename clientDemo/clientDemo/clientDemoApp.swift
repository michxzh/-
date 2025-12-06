//
//  clientDemoApp.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import SwiftUI

@main
struct clientDemoApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                
                NavigationStack {
                    MessageListView()
                }
                .tabItem {
                    Label("消息", systemImage: "message.fill")
                }

                NavigationStack {
                    DataBoardView()
                }
                .tabItem {
                    Label("数据", systemImage: "chart.bar")
                }
            }
        }
    }
}
