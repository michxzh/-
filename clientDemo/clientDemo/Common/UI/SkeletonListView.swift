//
//  SkeletonListView.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//
import SwiftUI

struct SkeletonListView: View {
    var body: some View {
        List(0..<8, id: \.self) { _ in
            HStack(spacing: 12) {

                // 左侧头像占位
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 8) {
                    // 昵称占位
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 14)

                    // 文本占位
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                }

                Spacer()
            }
            .redacted(reason: .placeholder)
        }
        .listStyle(.plain)
    }
}
