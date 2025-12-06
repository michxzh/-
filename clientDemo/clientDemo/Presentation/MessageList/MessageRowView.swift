import SwiftUI

struct MessageRowView: View {
    let message: Message
    let searchQuery: String

    var body: some View {
        HStack(spacing: 12) {

            // 头像
            Image(message.avatar)
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )

            // 文本区
            VStack(alignment: .leading, spacing: 8) {

                // 标题 + 时间
                HStack(spacing: 4) {

                    // 显示置顶图标
                    if message.isPinned == true {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                    }

                    highlightText(message.nickname)

                    Spacer()

                    Text(message.timeText)
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }

                // 摘要文本（高亮搜索）
                highlightText(message.summary)
                    .font(.system(size: 14))
                    .foregroundColor(.gray)

                // 内容类型展示（核心）
                switch message.contentType ?? .text {

                case .text:
                    EmptyView()

                case .image:
                    if let name = message.imageName {
                        Image(name)
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(height: 160)
                            .clipped()
                            .cornerRadius(10)
                    }

                case .action:
                    if let title = message.actionTitle {
                        Button(action: {
                            print("运营按钮点击：\(title)")
                        }) {
                            Text(title)
                                .font(.system(size: 14, weight: .medium))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 14)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }

                // 备注展示
                if let remark = message.remark, !remark.isEmpty {
                    Text("备注：\(remark)")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                }
            }

            // 未读角标
            if message.unreadCount > 0 {
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 20, height: 20)
                    Text("\(message.unreadCount)")
                        .foregroundColor(.white)
                        .font(.system(size: 12, weight: .bold))
                }
            }
        }
        .padding(.vertical, 8)
    }

    // 搜索匹配高亮
    private func highlightText(_ text: String) -> Text {
        guard !searchQuery.isEmpty,
              let range = text.range(of: searchQuery, options: .caseInsensitive) else {
            return Text(text)
        }

        let prefix = String(text[..<range.lowerBound])
        let match = String(text[range])
        let suffix = String(text[range.upperBound...])

        return Text(prefix) +
               Text(match).foregroundColor(.orange) +
               Text(suffix)
    }
}
