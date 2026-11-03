import SwiftUI

nonisolated extension CatalogEntry {
    static let link = CatalogEntry(
        id: "Link",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押すと URL を開くコントロール。Web の URL なら Safari で開く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/link")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "Apple のサイト"), required: true, summary: "名前"),
            .argument(
                "destination", .fixed(code: "URL(string: \"https://www.apple.com\")!"), required: true,
                summary: "開く URL"),
            .modifier(
                "buttonStyle",
                .choice([Choice(".automatic"), Choice(".bordered"), Choice(".borderedProminent")], initial: 1),
                summary: "見た目のスタイル。ボタンと同じスタイルが使える"),
            .modifier("tint", .color(initial: 5), on: true, summary: "文字の色"),
        ],
        code: CodeTemplate(call: "Link"),
        build: { v in
            AnyView(
                Link(v.text("title") ?? "", destination: URL(string: "https://www.apple.com")!)
                    .apply(v.pick("buttonStyle", from: LinkDemo.Style.allCases)) { LinkDemo.styled($0, $1) }
                    .apply(v.color("tint")) { $0.tint($1) }
            )
        }
    )
}

private enum LinkDemo {
    enum Style: CaseIterable {
        case automatic, bordered, borderedProminent
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.buttonStyle(.automatic)
        case .bordered: view.buttonStyle(.bordered)
        case .borderedProminent: view.buttonStyle(.borderedProminent)
        }
    }
}
