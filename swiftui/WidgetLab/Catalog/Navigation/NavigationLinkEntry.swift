import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationLink = CatalogEntry(
        id: "NavigationLink",
        kind: .view,
        topic: .navigation,
        summary: "押すと、NavigationStack に次の画面を積んで進む View。値を渡し、行き先は navigationDestination で決める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationlink")!,
        stage: .full,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "りんごを見る"), required: true, summary: "リンクの文"),
            .argument(
                "value", .fixed(code: "\"りんご\""), required: true, summary: "積む値。navigationDestination(for:) の型で行き先が決まる"),
            .modifier("disabled", .toggle(initial: true), summary: "true なら押せない"),
            .modifier("tint", .color(initial: 5), summary: "リンクの文の色（List の外のとき）"),
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    VStack {"], indent: 8, call: "NavigationLink",
            closing: ["    }", "    .navigationDestination(for: String.self) { Text($0) }", "}"]),
        build: { v in
            AnyView(
                NavigationStack {
                    VStack(spacing: 16) {
                        NavigationLink(v.text("title") ?? "", value: "りんご")
                            .apply(v.flag("disabled")) { $0.disabled($1) }
                            .apply(v.color("tint")) { $0.tint($1) }
                    }
                    .navigationDestination(for: String.self) { FruitScreen(name: $0) }
                    .navigationTitle("果物")
                })
        }
    )
}
