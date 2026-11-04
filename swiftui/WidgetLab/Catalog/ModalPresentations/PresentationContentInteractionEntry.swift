import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationContentInteraction = CatalogEntry(
        id: "presentationContentInteraction",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの中をスクロールしたとき、シートの高さを変えるか、中身をスクロールするかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/presentationcontentinteraction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationContentInteraction",
                .choice([Choice(".automatic"), Choice(".resizes"), Choice(".scrolls")], initial: 2), on: true,
                summary: "上へなぞったときの動き。.resizes は先にシートを広げ、.scrolls は中身をスクロールする")
        ],
        code: CodeTemplate(
            prefix: [
                "Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {",
            ], indent: 8, call: "List(1...30, id: \\.self)", trailing: " { Text(\"行 \\($0)\") }",
            suffix: [".presentationDetents([.medium, .large])"], closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    List(1...30, id: \.self) { Text("行 \($0)") }
                        .apply(
                            v.pick(
                                "presentationContentInteraction",
                                from: [PresentationContentInteraction.automatic, .resizes, .scrolls])
                        ) { $0.presentationContentInteraction($1) }
                        .presentationDetents([.medium, .large])
                })
        }
    )
}
