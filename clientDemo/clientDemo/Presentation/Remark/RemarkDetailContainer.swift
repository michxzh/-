//
//  RemarkDetailContainer.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//

// Presentation/Remark/RemarkDetailContainer.swift
import SwiftUI

struct RemarkDetailContainer: View {

    let message: Message
    let namespace: Namespace.ID
    let onClose: () -> Void
    let onSaveRemark: (String?) -> Void

    @State private var offset: CGFloat = 0

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture { close() }

            VStack {
                RemarkView(message: message, onSaveRemark: onSaveRemark)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
            )
            .matchedGeometryEffect(id: message.id, in: namespace)
            .offset(y: offset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = max(value.translation.height, 0)
                    }
                    .onEnded { value in
                        if value.translation.height > 150 {
                            close()
                        } else {
                            withAnimation(.spring()) {
                                offset = 0
                            }
                        }
                    }
            )
            .padding()
        }
    }

    private func close() {
        withAnimation(.spring()) {
            offset = 300
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onClose()
        }
    }
}
