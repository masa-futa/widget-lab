import SwiftUI

nonisolated extension CatalogEntry {
    static let pickerStyle = CatalogEntry(
        id: "pickerStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Picker の見た目と選び方を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/pickerstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "pickerStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".menu"), Choice(".segmented"), Choice(".wheel"),
                        Choice(".inline"),
                        Choice(".palette"),
                    ],
                    initial: 2),
                on: true, summary: "Picker の見た目のスタイル"),
            .modifier("tint", .color(initial: 6), summary: "強調の色（.menu の文字など）"),
        ],
        code: CodeTemplate(
            call: "Picker", fixedArguments: ["\"果物\"", "selection: $fruit"],
            trailing:
                " {\n    Text(\"りんご\").tag(\"りんご\")\n    Text(\"みかん\").tag(\"みかん\")\n    Text(\"ぶどう\").tag(\"ぶどう\")\n}"),
        build: { v in
            AnyView(
                PickerStyleDemo(
                    style: v.pick("pickerStyle", from: PickerStyleDemo.Style.allCases), tint: v.color("tint")))
        }
    )
}

private struct PickerStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, menu, segmented, wheel, inline, palette
    }

    let style: Style?
    let tint: Color?
    @State private var fruit = "りんご"

    var body: some View {
        // .wheel・.inline はプレビューの枠より高くなるので、収まらないときだけスクロールして見る
        ViewThatFits(in: .vertical) {
            styledPicker
            ScrollView { styledPicker }
        }
    }

    private var styledPicker: some View {
        Picker("果物", selection: $fruit) {
            Text("りんご").tag("りんご")
            Text("みかん").tag("みかん")
            Text("ぶどう").tag("ぶどう")
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.pickerStyle(.automatic)
            case .menu: view.pickerStyle(.menu)
            case .segmented: view.pickerStyle(.segmented)
            case .wheel: view.pickerStyle(.wheel)
            case .inline: view.pickerStyle(.inline)
            case .palette: view.pickerStyle(.palette)
            }
        }
        .apply(tint) { $0.tint($1) }
        .frame(width: 260)
    }
}
