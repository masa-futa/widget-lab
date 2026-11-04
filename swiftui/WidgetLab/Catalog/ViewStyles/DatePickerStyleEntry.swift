import SwiftUI

nonisolated extension CatalogEntry {
    static let datePickerStyle = CatalogEntry(
        id: "datePickerStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の DatePicker の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/datepickerstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "datePickerStyle",
                .choice(
                    [Choice(".automatic"), Choice(".compact"), Choice(".graphical"), Choice(".wheel")], initial: 2),
                on: true, summary: "DatePicker の見た目のスタイル"),
            .modifier("tint", .color(initial: 0), summary: "選んだ日の色"),
        ],
        code: CodeTemplate(
            call: "DatePicker", fixedArguments: ["\"日付\"", "selection: $date", "displayedComponents: .date"]),
        build: { v in
            AnyView(
                DatePickerStyleDemo(
                    style: v.pick("datePickerStyle", from: DatePickerStyleDemo.Style.allCases), tint: v.color("tint")))
        }
    )
}

private struct DatePickerStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, compact, graphical, wheel
    }

    let style: Style?
    let tint: Color?
    @State private var date = Date.now

    var body: some View {
        // .graphical・.wheel はプレビューの枠より高くなるので、収まらないときだけスクロールして見る
        ViewThatFits(in: .vertical) {
            styledPicker
            ScrollView { styledPicker }
        }
    }

    private var styledPicker: some View {
        DatePicker("日付", selection: $date, displayedComponents: .date)
            .apply(style) { view, style in
                switch style {
                case .automatic: view.datePickerStyle(.automatic)
                case .compact: view.datePickerStyle(.compact)
                case .graphical: view.datePickerStyle(.graphical)
                case .wheel: view.datePickerStyle(.wheel)
                }
            }
            .apply(tint) { $0.tint($1) }
            .frame(maxWidth: 320)
    }
}
