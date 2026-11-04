import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationCornerRadius = CatalogEntry(
        id: "presentationCornerRadius",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの角の丸みの半径を決める modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationcornerradius(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationCornerRadius", .slider(range: 0...60, step: 4, initial: 0), on: true,
                summary: "角の丸みの半径。省くとシステムの丸み")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(v.number("presentationCornerRadius")) { $0.presentationCornerRadius($1) }
                        .presentationDetents([.medium])
                })
        }
    )
}
