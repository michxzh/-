//
//  EmptyStateView.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
}
