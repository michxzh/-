//
//  DataBoardView.swift
//  clientDemo
//

import SwiftUI
import Charts

struct DataBoardView: View {

    private let store = AnalyticsStore()

    @State private var todayCount: Int = 0
    @State private var ctrList: [(String, Double)] = []
    @State private var trend: [(String, Int)] = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                // 折线图：最近 7 日新增消息
                Section {
                    Chart {
                        ForEach(trend, id: \.0) { (day, count) in
                            LineMark(
                                x: .value("日期", day),
                                y: .value("新增消息", count)
                            )
                            .foregroundStyle(.blue)
                            .symbol(.circle)
                            .interpolationMethod(.monotone)
                        }
                    }
                    .frame(height: 200)
                } header: {
                    Text("最近 7 天新增消息趋势")
                        .font(.headline)
                }

                // MARK: - 今日消息数
                VStack(alignment: .leading) {
                    Text("今日新增消息")
                        .font(.headline)
                    Text("\(todayCount)")
                        .font(.largeTitle.bold())
                        .foregroundColor(.blue)
                }

                Divider()

                // CTR 列表 + 饼图
                VStack(alignment: .leading, spacing: 12) {

                    Text("消息类型 CTR（点击率）")
                        .font(.headline)

                    // CTR 数字列表
                    ForEach(ctrList, id: \.0) { (type, ctr) in
                        HStack {
                            Text(type.isEmpty ? "未知类型" : type)
                            Spacer()
                            Text(String(format: "%.1f%%", ctr * 100))
                                .bold()
                        }
                        .padding(.vertical, 4)
                    }

                    // CTR 饼图
                    Chart {
                        ForEach(ctrList, id: \.0) { (type, ctr) in
                            SectorMark(
                                angle: .value("CTR", ctr),
                                innerRadius: .ratio(0.5),
                                outerRadius: .ratio(1.0)
                            )
                            .foregroundStyle(by: .value("类型", type))
                        }
                    }
                    .frame(height: 240)

                }

                Divider()

                // 最近 7 日新增表格
                VStack(alignment: .leading, spacing: 12) {
                    Text("最近 7 天新增消息")
                        .font(.headline)

                    ForEach(trend, id: \.0) { (day, count) in
                        HStack {
                            Text(day)
                            Spacer()
                            Text("\(count)")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("数据看板")
        .onAppear { reload() }
    }

    private func reload() {
        todayCount = store.countTodayMessages()
        ctrList = store.messageCTRByType()
        trend = store.unreadTrend(lastDays: 7)
    }
}
