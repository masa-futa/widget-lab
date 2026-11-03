import SwiftUI

nonisolated extension CatalogEntry {
    static let label = CatalogEntry(
        id: "Label",
        kind: .view,
        topic: .textInputAndOutput,
        summary: "文字とアイコンを組にして出す、ふつうの見出しの View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/label")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "ダウンロード"), required: true, summary: "見出しの文字"),
            .argument(
                "systemImage",
                .choice([Choice("\"arrow.down.circle\""), Choice("\"star.fill\""), Choice("\"bell\"")], initial: 0),
                required: true, summary: "アイコン（SF Symbols の名前）"),
            .modifier(
                "labelStyle",
                .choice(
                    [Choice(".automatic"), Choice(".titleAndIcon"), Choice(".titleOnly"), Choice(".iconOnly")],
                    initial: 1),
                on: true, summary: "文字とアイコンのどちらを出すか"),
            .modifier(
                "font", .choice([Choice(".title"), Choice(".body"), Choice(".caption")], initial: 0),
                on: true, summary: "文字とアイコンの大きさ"),
        ],
        code: CodeTemplate(call: "Label"),
        build: { v in
            AnyView(
                Label(
                    v.text("title") ?? "",
                    systemImage: v.pick("systemImage", from: ["arrow.down.circle", "star.fill", "bell"])
                        ?? "arrow.down.circle"
                )
                .apply(v.pick("labelStyle", from: LabelDemo.Style.allCases)) { LabelDemo.styled($0, $1) }
                .apply(v.pick("font", from: [Font.title, .body, .caption])) { $0.font($1) }
            )
        }
    )
}

private enum LabelDemo {
    enum Style: CaseIterable {
        case automatic, titleAndIcon, titleOnly, iconOnly
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.labelStyle(.automatic)
        case .titleAndIcon: view.labelStyle(.titleAndIcon)
        case .titleOnly: view.labelStyle(.titleOnly)
        case .iconOnly: view.labelStyle(.iconOnly)
        }
    }
}
