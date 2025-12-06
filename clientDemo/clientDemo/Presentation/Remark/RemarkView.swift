//
//  RemarkView.swift
//  clientDemo
//
//  Created by Zihao Xie on 2025/12/6.
//


import SwiftUI

struct RemarkView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: RemarkViewModel

    let onSaveRemark: (String?) -> Void

    init(message: Message, onSaveRemark: @escaping (String?) -> Void) {
        _viewModel = StateObject(wrappedValue: RemarkViewModel(message: message))
        self.onSaveRemark = onSaveRemark
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("昵称")
                .font(.headline)
            Text(viewModel.message.nickname)
                .font(.title3)
                .padding(.bottom, 8)

            Text("备注")
                .font(.headline)

            TextEditor(text: $viewModel.remarkText)
                .frame(minHeight: 150)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )

            Spacer()

            Button {
                viewModel.saveRemark()
                onSaveRemark(viewModel.remarkText.isEmpty ? nil : viewModel.remarkText)
                dismiss()
            } label: {
                Text("保存")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .navigationTitle("备注")
        .navigationBarTitleDisplayMode(.inline)
    }
}
