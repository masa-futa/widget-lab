import SwiftUI

nonisolated extension CatalogEntry {
    static let interactiveDismissDisabled = CatalogEntry(
        id: "interactiveDismissDisabled",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートや吹き出しを、指で下げたり外を押したりして閉じられないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/interactivedismissdisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "interactiveDismissDisabled", .toggle(initial: true), on: true,
                summary: "true なら指では閉じられない。閉じるボタン（dismiss）では閉じる")
        ],
        code: .inSheet("閉じるボタンでだけ閉じる"),
        build: { v in
            AnyView(
                SheetModifierDemo {
                    ModalSheetContent("閉じるボタンでだけ閉じる")
                        .apply(v.flag("interactiveDismissDisabled")) { $0.interactiveDismissDisabled($1) }
                })
        }
    )
}
