//
//  ErrorStateView.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//
import SwiftUI

struct ErrorStateView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("加载失败")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.gray)
            Button("重试", action: onRetry)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
        }
        .padding()
    }
}
