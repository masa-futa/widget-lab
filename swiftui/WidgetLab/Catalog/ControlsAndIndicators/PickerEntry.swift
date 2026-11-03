import SwiftUI

nonisolated extension CatalogEntry {
    static let picker = CatalogEntry(
        id: "Picker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "いくつかの中から 1 つを選ぶコントロール。選択肢は tag の値で見分ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/picker")!,
        stage: .card,
        properties: [
            .modifier(
                "pickerStyle",
                .choice(
                    [Choice(".automatic"), Choice(".menu"), Choice(".segmented"), Choice(".wheel"), Choice(".inline")],
                    initial: 2),
                on: true, summary: "見た目のスタイル"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
            .modifier("tint", .color(initial: 6), summary: "強調の色（.menu の文字など）"),
        ],
        code: CodeTemplate(
            call: "Picker", fixedArguments: ["\"果物\"", "selection: $fruit"],
            trailing:
                " {\n    Text(\"りんご\").tag(\"りんご\")\n    Text(\"みかん\").tag(\"みかん\")\n    Text(\"ぶどう\").tag(\"ぶどう\")\n}"),
        build: { v in
            AnyView(
                PickerDemo(
                    style: v.pick("pickerStyle", from: PickerDemo.Style.allCases), hidesLabel: v["labelsHidden"] != nil,
                    tint: v.color("tint")))
        }
    )
}

private struct PickerDemo: View {
    enum Style: CaseIterable {
        case automatic, menu, segmented, wheel, inline
    }

    let style: Style?
    let hidesLabel: Bool
    let tint: Color?
    @State private var fruit = "りんご"

    var body: some View {
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
            }
        }
        .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
        .apply(tint) { $0.tint($1) }
        .frame(width: 260)
    }
}
