import SwiftUI

nonisolated extension CatalogEntry {
    static let toggleStyle = CatalogEntry(
        id: "toggleStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Toggle の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/togglestyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "toggleStyle", .choice([Choice(".automatic"), Choice(".switch"), Choice(".button")], initial: 2),
                on: true, summary: "Toggle の見た目のスタイル。.button は押すたびに色が変わるボタンになる"),
            .modifier("tint", .color(initial: 4), summary: "ON のときの色"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    Toggle(\"通知\", isOn: $notifies)\n    Toggle(\"音\", isOn: $sounds)\n}"),
        build: { v in
            AnyView(
                ToggleStyleDemo(
                    style: v.pick("toggleStyle", from: ToggleStyleDemo.Style.allCases), tint: v.color("tint"))
            )
        }
    )
}

private struct ToggleStyleDemo: View {
    enum Style: CaseIterable {
        case automatic, `switch`, button
    }

    let style: Style?
    let tint: Color?
    @State private var notifies = true
    @State private var sounds = false

    var body: some View {
        VStack {
            Toggle("通知", isOn: $notifies)
            Toggle("音", isOn: $sounds)
        }
        .apply(style) { view, style in
            switch style {
            case .automatic: view.toggleStyle(.automatic)
            case .switch: view.toggleStyle(.switch)
            case .button: view.toggleStyle(.button)
            }
        }
        .apply(tint) { $0.tint($1) }
        .frame(width: 220)
    }
}
