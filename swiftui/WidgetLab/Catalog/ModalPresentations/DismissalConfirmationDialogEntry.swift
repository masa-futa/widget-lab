import SwiftUI

nonisolated extension CatalogEntry {
    static let dismissalConfirmationDialog = CatalogEntry(
        id: "dismissalConfirmationDialog",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "この View を出している画面を閉じようとしたとき、閉じてよいかを確かめるダイアログを出す modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/dismissalconfirmationdialog(_:shouldpresent:actions:)"
        )!,
        noteReason: "iOS では窓（シーン）を閉じる操作で出る。iPhone でシートを指で下げても出なかった。iPad で窓を閉じるときや、Mac で効く",
        properties: [
            .modifier(
                "dismissalConfirmationDialog",
                .fixed(
                    code:
                        "\"書きかけを捨てますか？\", shouldPresent: !memo.isEmpty, actions: { Button(\"捨てる\", role: .destructive) { } }"
                ),
                on: true, summary: "題名・出すかどうか（書きかけがあるとき）・ボタン")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "TextField", fixedArguments: ["\"メモ\"", "text: $memo"], closing: ["    }"])
    )
}
