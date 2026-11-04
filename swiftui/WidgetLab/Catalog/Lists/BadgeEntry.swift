import SwiftUI

nonisolated extension CatalogEntry {
    static let badge = CatalogEntry(
        id: "badge",
        kind: .modifier,
        topic: .lists,
        summary: "List の行やタブの項目に、数や短い文字のバッジを付ける modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/badge(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "badge", .choice([Choice("3"), Choice("\"新着\""), Choice("0")], initial: 0), on: true,
                summary: "バッジの中身（数の 0 は出さない）"),
            .modifier(
                "badgeProminence",
                .choice([Choice(".standard"), Choice(".increased"), Choice(".decreased")], initial: 1),
                summary: "バッジの目立たせ方"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Text", fixedArguments: ["\"受信\""], closing: ["    Text(\"送信済み\")", "}"]),
        build: { v in
            AnyView(
                List {
                    Text("受信")
                        .apply(v.pick("badge", from: [0, 1, 2])) { view, i in
                            switch i {
                            case 0: view.badge(3)
                            case 1: view.badge("新着")
                            default: view.badge(0)
                            }
                        }
                        .apply(v.pick("badgeProminence", from: [BadgeProminence.standard, .increased, .decreased])) {
                            $0.badgeProminence($1)
                        }
                    Text("送信済み")
                }
            )
        }
    )
}
