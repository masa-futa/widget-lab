import SwiftUI

nonisolated extension CatalogEntry {
    static let toggle = CatalogEntry(
        id: "Toggle",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "ON と OFF を切り替えるコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/toggle")!,
        stage: .card,
        properties: [
            .modifier(
                "toggleStyle", .choice([Choice(".automatic"), Choice(".switch"), Choice(".button")], initial: 2),
                on: true, summary: "見た目のスタイル。.button は押すたびに色が変わるボタンになる"),
            .modifier("tint", .color(initial: 1), summary: "ON のときの色"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(call: "Toggle", fixedArguments: ["\"通知\"", "isOn: $isOn"]),
        build: { v in
            AnyView(
                ToggleDemo(
                    style: v.pick("toggleStyle", from: ToggleDemo.Style.allCases), tint: v.color("tint"),
                    hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct ToggleDemo: View {
    enum Style: CaseIterable {
        case automatic, `switch`, button
    }

    let style: Style?
    let tint: Color?
    let hidesLabel: Bool
    @State private var isOn = true

    var body: some View {
        Toggle("通知", isOn: $isOn)
            .apply(style) { view, style in
                switch style {
                case .automatic: view.toggleStyle(.automatic)
                case .switch: view.toggleStyle(.switch)
                case .button: view.toggleStyle(.button)
                }
            }
            .apply(tint) { $0.tint($1) }
            .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            .fixedSize()
    }
}
