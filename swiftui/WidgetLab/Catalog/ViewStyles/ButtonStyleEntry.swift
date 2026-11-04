import SwiftUI

nonisolated extension CatalogEntry {
    static let buttonStyle = CatalogEntry(
        id: "buttonStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中のボタンの見た目を、まとめて決める modifier。押したときの動きはそのまま。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/buttonstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "buttonStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent"), Choice(".borderless"),
                        Choice(".plain"), Choice(".glass"), Choice(".glassProminent"),
                    ],
                    initial: 2),
                on: true, summary: "ボタンの見た目のスタイル"),
            .modifier(
                "buttonBorderShape", .choice([Choice(".capsule"), Choice(".roundedRectangle")], initial: 1),
                summary: "枠のあるスタイルでの、枠の形"),
            .modifier(
                "controlSize", .choice([Choice(".small"), Choice(".regular"), Choice(".large")], initial: 2),
                summary: "ボタンの大きさ"),
            .modifier("tint", .color(initial: 3), summary: "ボタンの色"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    Button(\"保存\") { }\n    Button(\"削除\", role: .destructive) { }\n}"),
        build: { v in
            AnyView(
                VStack {
                    Button("保存") {}
                    Button("削除", role: .destructive) {}
                }
                .apply(v.pick("buttonStyle", from: ButtonStyleDemo.Style.allCases)) { ButtonStyleDemo.styled($0, $1) }
                .apply(v.pick("buttonBorderShape", from: [ButtonBorderShape.capsule, .roundedRectangle])) {
                    $0.buttonBorderShape($1)
                }
                .apply(v.pick("controlSize", from: [ControlSize.small, .regular, .large])) { $0.controlSize($1) }
                .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private enum ButtonStyleDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent, borderless, plain, glass, glassProminent
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
        case .glassProminent: view.buttonStyle(.glassProminent)
        }
    }
}
