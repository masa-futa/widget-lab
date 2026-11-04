import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let newDocumentButton = CatalogEntry(
        id: "NewDocumentButton",
        kind: .view,
        topic: .documents,
        summary: "押すと、新しい書類を作って開くボタン。DocumentLaunchView の中などに置く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/newdocumentbutton")!,
        stage: .full,
        properties: [
            .argument(
                "title", unlabeled: true, .text(initial: "新しいメモ"), required: true,
                summary: "ボタンの文。DocumentGroup のアプリでは、押すと新しい書類を作って開く（この見本は DocumentGroup の外なので、押しても開かない）"),
            .argument("contentType", .fixed(code: ".plainText"), summary: "作る書類の種類。省くと、アプリの最初の種類"),
        ],
        code: CodeTemplate(
            prefix: ["DocumentLaunchView(\"メモ\", for: [.plainText]) {"], call: "NewDocumentButton",
            closing: ["} onDocumentOpen: { url in", "    Text(url.lastPathComponent)", "}"]),
        build: { v in
            AnyView(
                DocumentLaunchView("メモ", for: [.plainText]) {
                    if v["contentType"] != nil {
                        NewDocumentButton(LocalizedStringKey(v.text("title") ?? ""), contentType: .plainText)
                    } else {
                        NewDocumentButton(LocalizedStringKey(v.text("title") ?? ""))
                    }
                } onDocumentOpen: { url in
                    Text(url.lastPathComponent)
                })
        }
    )
}
