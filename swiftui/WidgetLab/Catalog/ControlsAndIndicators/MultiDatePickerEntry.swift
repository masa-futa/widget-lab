import SwiftUI

nonisolated extension CatalogEntry {
    static let multiDatePicker = CatalogEntry(
        id: "MultiDatePicker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "カレンダーで、日付をいくつも選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/multidatepicker")!,
        stage: .card,
        properties: [
            .argument(
                "in", .choice([Choice("今日から", code: "Date.now..."), Choice("今日より前", code: "..<Date.now")], initial: 0),
                on: true, summary: "選べる範囲。外の日は薄くなり、選べない"),
            .modifier("tint", .color(initial: 3), summary: "選んだ日の色"),
        ],
        code: CodeTemplate(call: "MultiDatePicker", fixedArguments: ["\"予定の日\"", "selection: $dates"]),
        build: { v in
            AnyView(
                MultiDatePickerDemo(range: v.pick("in", from: MultiDatePickerDemo.Range.allCases))
                    .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private struct MultiDatePickerDemo: View {
    enum Range: CaseIterable {
        case fromNow, beforeNow
    }

    let range: Range?
    @State private var dates: Set<DateComponents> = []

    var body: some View {
        // カレンダーはプレビューの枠より高いので、スクロールして見る（一覧の行の見本も、行の高さに収まる）
        ScrollView {
            VStack(spacing: 4) {
                Text("選んだ日: \(dates.count)")
                    .font(.caption)
                    .monospacedDigit()
                picker
            }
            .frame(maxWidth: 320)
        }
        // 最後の週が、プレビューの右下の「比べる」に隠れないようにする
        .contentMargins(.bottom, 60, for: .scrollContent)
    }

    @ViewBuilder
    private var picker: some View {
        switch range {
        case .fromNow: MultiDatePicker("予定の日", selection: $dates, in: Date.now...)
        case .beforeNow: MultiDatePicker("予定の日", selection: $dates, in: ..<Date.now)
        case nil: MultiDatePicker("予定の日", selection: $dates)
        }
    }
}
