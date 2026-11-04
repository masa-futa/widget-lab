import SwiftUI

nonisolated extension CatalogEntry {
    static let sceneAccessory = CatalogEntry(
        id: "sceneAccessory",
        kind: .modifier,
        topic: .scenes,
        summary: "窓（シーン）に、付属の画面を結び付ける modifier。iPhone では、つないだ外のディスプレイに、操作できない画面を出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/sceneaccessory(content:)")!,
        noteReason: "iPhone に外のディスプレイをつないだときに、そのディスプレイに出る。アプリの画面の中には出ない",
        properties: [
            .modifier(
                "sceneAccessory",
                .fixed(code: "content: { ExternalNonInteractiveAccessory { Text(\"つないだ画面に出す\") } }"), on: true,
                summary: "付属の画面。ExternalNonInteractiveAccessory は、外のディスプレイに操作できない画面を出す")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"本体の画面\""])
    )
}
