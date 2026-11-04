import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationDragIndicator = CatalogEntry(
        id: "presentationDragIndicator",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの上の端に、指でつまむ印（グラバー）を出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationdragindicator(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationDragIndicator",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 1), on: true,
                summary: "印を出すか。.automatic は止まる高さが 2 つ以上のときに出す")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(v.pick("presentationDragIndicator", from: [Visibility.automatic, .visible, .hidden])) {
                            $0.presentationDragIndicator($1)
                        }
                        .presentationDetents([.medium])
                })
        }
    )
}
