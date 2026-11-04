import SwiftUI

nonisolated extension CatalogEntry {
    static let menuStyle = CatalogEntry(
        id: "menuStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Menu の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menustyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuStyle",
                .choice([Choice(".automatic"), Choice(".button"), Choice(".borderlessButton")], initial: 2),
                on: true, summary: "Menu の見た目のスタイル。iOS 27 では .automatic と .button が枠のあるボタン、.borderlessButton が文字だけになる"),
            .modifier(
                "buttonStyle", .choice([Choice(".bordered"), Choice(".borderedProminent")], initial: 1),
                summary: "ボタンのスタイル（.automatic・.button の Menu に効く）"),
        ],
        code: CodeTemplate(
            call: "Menu", fixedArguments: ["\"並べ替え\""],
            trailing: " {\n    Button(\"名前順\") { }\n    Button(\"日付順\") { }\n}"),
        build: { v in
            AnyView(
                Menu("並べ替え") {
                    Button("名前順") {}
                    Button("日付順") {}
                }
                .apply(v.pick("menuStyle", from: MenuStyleDemo.Style.allCases)) { MenuStyleDemo.styled($0, $1) }
                .apply(v.pick("buttonStyle", from: [false, true])) { view, prominent in
                    if prominent { view.buttonStyle(.borderedProminent) } else { view.buttonStyle(.bordered) }
                }
            )
        }
    )
}

private enum MenuStyleDemo {
    enum Style: CaseIterable {
        case automatic, button, borderlessButton
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.menuStyle(.automatic)
        case .button: view.menuStyle(.button)
        case .borderlessButton: view.menuStyle(.borderlessButton)
        }
    }
}
