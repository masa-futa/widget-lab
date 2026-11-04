import SwiftUI

nonisolated extension CatalogEntry {
    static let headerProminence = CatalogEntry(
        id: "headerProminence",
        kind: .modifier,
        topic: .lists,
        summary: "節（Section）の見出しの目立たせ方を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/headerprominence(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "headerProminence", .choice([Choice(".increased"), Choice(".standard")], initial: 0), on: true,
                summary: "見出しの目立たせ方")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Section", fixedArguments: ["\"果物\""],
            trailing: " {\n        Text(\"りんご\")\n    }", closing: ["    Section(\"野菜\") { Text(\"にんじん\") }", "}"]),
        build: { v in
            AnyView(
                List {
                    Section("果物") { Text("りんご") }
                        .apply(v.pick("headerProminence", from: [Prominence.increased, .standard])) {
                            $0.headerProminence($1)
                        }
                    Section("野菜") { Text("にんじん") }
                }
            )
        }
    )
}
