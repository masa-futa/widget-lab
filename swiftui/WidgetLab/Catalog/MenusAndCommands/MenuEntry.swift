import SwiftUI

nonisolated extension CatalogEntry {
    static let menu = CatalogEntry(
        id: "Menu",
        kind: .view,
        topic: .menusAndCommands,
        summary: "押すと、操作の一覧（メニュー）を出すコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/menu")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "並べ替え"), required: true, summary: "名前"),
            .modifier(
                "buttonStyle",
                .choice(
                    [Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent"), Choice(".glass")],
                    initial: 1),
                on: true, summary: "押す部分の見た目。ボタンと同じスタイルが使える"),
            .modifier("tint", .color(initial: 4), summary: "強調の色"),
        ],
        code: CodeTemplate(
            call: "Menu",
            trailing:
                " {\n    Button(\"名前\") { }\n    Button(\"日付\") { }\n    Button(\"削除\", role: .destructive) { }\n}"),
        build: { v in
            AnyView(
                Menu(v.text("title") ?? "") {
                    Button("名前") {}
                    Button("日付") {}
                    Button("削除", role: .destructive) {}
                }
                .apply(v.pick("buttonStyle", from: MenuDemo.Style.allCases)) { MenuDemo.styled($0, $1) }
                .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private enum MenuDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent, glass
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        case .glass: view.buttonStyle(.glass)
        }
    }
}
