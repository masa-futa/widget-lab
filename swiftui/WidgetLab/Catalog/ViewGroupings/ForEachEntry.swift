import SwiftUI

nonisolated extension CatalogEntry {
    static let forEach = CatalogEntry(
        id: "ForEach",
        kind: .view,
        topic: .viewGroupings,
        summary: "データの 1 件ずつから View を作って並べる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/foreach")!,
        stage: .card,
        properties: [
            .argument(
                "data", unlabeled: true, .choice([Choice("0..<3"), Choice("0..<5"), Choice("1...8")], initial: 0),
                required: true, summary: "並べるデータ"),
            .argument(
                "id", .fixed(code: "\\.self"), on: true,
                summary: "1 件ずつを見分ける値（数の範囲のデータでは OFF にできる。範囲が変わるときは要る）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "ForEach", trailing: " { i in\n        Text(\"行 \\(i)\")\n    }", closing: ["}"]
        ),
        build: { v in
            let data = v.pick("data", from: [Array(0..<3), Array(0..<5), Array(1...8)]) ?? []
            return AnyView(
                VStack {
                    ForEach(data, id: \.self) { i in
                        Text("行 \(i)")
                    }
                }
            )
        }
    )
}
