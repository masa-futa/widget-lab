import SwiftUI

nonisolated extension CatalogEntry {
    static let button = CatalogEntry(
        id: "Button",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押したときに処理を行うコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/button")!,
        stage: .card,
        properties: [
            .argument(
                "role", .choice([Choice(".destructive"), Choice(".cancel")], initial: 0),
                summary: "ボタンの役割。destructive は削除などの取り消せない操作"),
            .modifier(
                "buttonStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent"), Choice(".borderless"),
                        Choice(".plain"), Choice(".glass"),
                    ],
                    initial: 2),
                on: true, summary: "ボタンの見た目のスタイル"),
            .modifier(
                "controlSize",
                .choice(
                    [Choice(".mini"), Choice(".small"), Choice(".regular"), Choice(".large"), Choice(".extraLarge")],
                    initial: 3),
                summary: "コントロールの大きさ"),
            .modifier("tint", .color(initial: 4), summary: "強調の色"),
            .modifier("disabled", .toggle(initial: true), summary: "押せなくする"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"),
        build: { v in
            AnyView(
                ButtonDemo.button(role: v.pick("role", from: [ButtonRole.destructive, .cancel]))
                    .apply(v.pick("buttonStyle", from: ButtonDemo.Style.allCases)) { view, style in
                        ButtonDemo.styled(view, style)
                    }
                    .apply(v.pick("controlSize", from: [ControlSize.mini, .small, .regular, .large, .extraLarge])) {
                        $0.controlSize($1)
                    }
                    .apply(v.color("tint")) { $0.tint($1) }
                    .apply(v.flag("disabled")) { $0.disabled($1) }
            )
        }
    )
}

private enum ButtonDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent, borderless, plain, glass
    }

    @ViewBuilder
    static func button(role: ButtonRole?) -> some View {
        if let role {
            Button("保存", role: role) {}
        } else {
            Button("保存") {}
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        case .borderless: view.buttonStyle(.borderless)
        case .plain: view.buttonStyle(.plain)
        case .glass: view.buttonStyle(.glass)
        }
    }
}
