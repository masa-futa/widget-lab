import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationDetents = CatalogEntry(
        id: "presentationDetents",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートが止まる高さ（半分・いっぱいなど）を決める modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationdetents(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationDetents",
                .choice(
                    [
                        Choice("[.medium]"), Choice("[.medium, .large]"), Choice("[.height(200)]"),
                        Choice("[.fraction(0.3), .large]"),
                    ], initial: 1), on: true,
                summary: "止まる高さの集まり。2 つ以上なら、指で上下させて切り替えられる")
        ],
        code: .inSheet(),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("シートの中身")
                        .apply(
                            v.pick(
                                "presentationDetents",
                                from: [
                                    Set<PresentationDetent>([.medium]), [.medium, .large], [.height(200)],
                                    [.fraction(0.3), .large],
                                ])
                        ) { $0.presentationDetents($1) }
                })
        }
    )
}
