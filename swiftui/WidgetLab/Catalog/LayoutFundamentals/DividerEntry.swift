import SwiftUI

nonisolated extension CatalogEntry {
    static let divider = CatalogEntry(
        id: "Divider",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "中身を区切る線。並びの向きに交わる向きに引く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/divider")!,
        stage: .card,
        properties: [
            .modifier("overlay", .color(initial: 0), summary: "線の色（線の上に色を重ねる）"),
            .modifier(
                "padding", .choice([Choice(".horizontal"), Choice(".vertical")], initial: 0),
                summary: "線のまわりの余白"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"上\")"], call: "Divider", closing: ["    Text(\"下\")", "}"]),
        build: { v in
            AnyView(
                VStack {
                    Text("上")
                    Divider()
                        .apply(v.color("overlay")) { $0.overlay($1) }
                        .apply(v.pick("padding", from: [Edge.Set.horizontal, .vertical])) { $0.padding($1) }
                    Text("下")
                }
                .frame(width: 200)
                .border(.secondary)
            )
        }
    )
}
