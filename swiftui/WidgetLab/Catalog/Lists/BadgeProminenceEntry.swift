import SwiftUI

nonisolated extension CatalogEntry {
    static let badgeProminence = CatalogEntry(
        id: "badgeProminence",
        kind: .modifier,
        topic: .lists,
        summary: "バッジの目立たせ方（.increased は色の付いた丸）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/badgeprominence(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "badgeProminence",
                .choice([Choice(".increased"), Choice(".decreased"), Choice(".standard")], initial: 0), on: true,
                summary: "バッジの目立たせ方")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Text(\"受信\").badge(3)\n    Text(\"下書き\").badge(\"新着\")\n}"),
        build: { v in
            AnyView(
                List {
                    Text("受信").badge(3)
                    Text("下書き").badge("新着")
                }
                .apply(v.pick("badgeProminence", from: [BadgeProminence.increased, .decreased, .standard])) {
                    $0.badgeProminence($1)
                }
            )
        }
    )
}
