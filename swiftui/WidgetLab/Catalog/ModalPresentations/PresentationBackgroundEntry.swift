import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationBackground = CatalogEntry(
        id: "presentationBackground",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの背景を、色や素材（すりガラス）で塗る modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationbackground(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationBackground",
                .choice(
                    [Choice(".yellow"), Choice(".ultraThinMaterial"), Choice(".blue.gradient"), Choice(".clear")],
                    initial: 0), on: true,
                summary: "背景の塗り。.clear なら、後ろの画面が透けて見える")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"]),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(
                            v.pick(
                                "presentationBackground",
                                from: [
                                    AnyShapeStyle(.yellow), AnyShapeStyle(.ultraThinMaterial),
                                    AnyShapeStyle(.blue.gradient), AnyShapeStyle(.clear),
                                ])
                        ) { $0.presentationBackground($1) }
                        .presentationDetents([.medium])
                })
        }
    )
}
