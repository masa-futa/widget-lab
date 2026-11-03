import SwiftUI

nonisolated extension CatalogEntry {
    static let editButton = CatalogEntry(
        id: "EditButton",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押すたびに編集モード（環境の editMode）を切り替えるボタン。List の行の削除や並べ替えに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/editbutton")!,
        stage: .card,
        properties: [
            .modifier(
                "buttonStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent")], initial: 1),
                on: true, summary: "ボタンの見た目のスタイル"),
            .modifier("tint", .color(initial: 4), summary: "強調の色"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "EditButton",
            closing: [
                "    List {",
                "        ForEach(items, id: \\.self) { Text($0) }",
                "            .onDelete { items.remove(atOffsets: $0) }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                EditButtonDemo(
                    style: v.pick("buttonStyle", from: EditButtonDemo.Style.allCases), tint: v.color("tint")))
        }
    )
}

private struct EditButtonDemo: View {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent
    }

    let style: Style?
    let tint: Color?
    @State private var items = ["りんご", "みかん", "ぶどう"]

    var body: some View {
        VStack {
            EditButton()
                .apply(style) { view, style in
                    switch style {
                    case .automatic: view.buttonStyle(.automatic)
                    case .bordered: view.buttonStyle(.bordered)
                    case .borderedProminent: view.buttonStyle(.borderedProminent)
                    }
                }
                .apply(tint) { $0.tint($1) }
            List {
                ForEach(items, id: \.self) { Text($0) }
                    .onDelete { items.remove(atOffsets: $0) }
            }
        }
    }
}
