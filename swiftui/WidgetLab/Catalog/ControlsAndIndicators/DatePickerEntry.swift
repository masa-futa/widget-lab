import SwiftUI

nonisolated extension CatalogEntry {
    static let datePicker = CatalogEntry(
        id: "DatePicker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "日付と時刻を選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/datepicker")!,
        stage: .card,
        properties: [
            .argument(
                "in", .choice([Choice("今日から", code: "Date.now..."), Choice("今日まで", code: "...Date.now")], initial: 0),
                summary: "選べる範囲。外の日は選べない"),
            .argument(
                "displayedComponents",
                .choice([Choice(".date"), Choice(".hourAndMinute"), Choice("[.date, .hourAndMinute]")], initial: 0),
                on: true, summary: "選ぶ項目。省くと日付と時刻の両方"),
            .modifier(
                "datePickerStyle",
                .choice(
                    [Choice(".automatic"), Choice(".compact"), Choice(".graphical"), Choice(".wheel")], initial: 1),
                on: true, summary: "見た目のスタイル"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(call: "DatePicker", fixedArguments: ["\"日付\"", "selection: $date"]),
        build: { v in
            AnyView(
                DatePickerDemo(
                    range: v.pick("in", from: DatePickerDemo.Range.allCases),
                    components: v.pick("displayedComponents", from: [.date, .hourAndMinute, [.date, .hourAndMinute]]),
                    style: v.pick("datePickerStyle", from: DatePickerDemo.Style.allCases),
                    hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct DatePickerDemo: View {
    enum Range: CaseIterable {
        case fromNow, throughNow
    }

    enum Style: CaseIterable {
        case automatic, compact, graphical, wheel
    }

    let range: Range?
    let components: DatePickerComponents?
    let style: Style?
    let hidesLabel: Bool
    @State private var date = Date.now

    var body: some View {
        // .graphical・.wheel はプレビューの枠より高くなるので、収まらないときだけスクロールして見る
        ViewThatFits(in: .vertical) {
            styledPicker
            ScrollView { styledPicker }
        }
    }

    private var styledPicker: some View {
        picker
            .apply(style) { view, style in
                switch style {
                case .automatic: view.datePickerStyle(.automatic)
                case .compact: view.datePickerStyle(.compact)
                case .graphical: view.datePickerStyle(.graphical)
                case .wheel: view.datePickerStyle(.wheel)
                }
            }
            .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            .frame(maxWidth: 320)
    }

    @ViewBuilder
    private var picker: some View {
        let components = components ?? [.date, .hourAndMinute]
        switch range {
        case .fromNow: DatePicker("日付", selection: $date, in: Date.now..., displayedComponents: components)
        case .throughNow: DatePicker("日付", selection: $date, in: ...Date.now, displayedComponents: components)
        case nil: DatePicker("日付", selection: $date, displayedComponents: components)
        }
    }
}
