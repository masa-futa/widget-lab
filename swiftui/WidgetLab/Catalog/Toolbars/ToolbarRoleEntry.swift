import SwiftUI

nonisolated extension CatalogEntry {
    static let toolbarRole = CatalogEntry(
        id: "toolbarRole",
        kind: .modifier,
        topic: .toolbars,
        summary: "ツールバーの役割（ふつうの画面・ブラウザ・編集の画面）を決める modifier。役割に合わせて、題名や戻るボタンの出し方が変わる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/toolbarrole(_:)")!,
        noteReason: "iOS 27.0 の iPhone 17 で .browser・.editor にしても、題名と戻るボタンの出し方は変わらなかった。iPad で、題名を左に寄せるなどの違いが出る",
        properties: [
            .modifier(
                "toolbarRole",
                .choice(
                    [Choice(".automatic"), Choice(".navigationStack"), Choice(".browser"), Choice(".editor")],
                    initial: 3), on: true,
                summary: "役割。.editor は書類を編集する画面、.browser は中を見て回る画面")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {", "    List(fruits, id: \\.self) { NavigationLink($0, value: $0) }"],
            indent: 8, call: ".navigationTitle", fixedArguments: ["\"果物\""],
            suffix: [".navigationDestination(for: String.self) { Text($0) }"], closing: ["}"])
    )
}
