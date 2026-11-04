import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let documentLaunchView = CatalogEntry(
        id: "DocumentLaunchView",
        kind: .view,
        topic: .documents,
        summary: "書類を扱うアプリの、起動のときの画面。題名と、書類を作る・開くボタンを出し、下に書類の一覧を出す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/documentlaunchview")!,
        stage: .full,
        properties: [
            .argument(
                "title", unlabeled: true, .text(initial: "メモ"), required: true, summary: "上に出す題名。下の書類の一覧は、出るまで数秒かかる"),
            .argument("for", .fixed(code: "[.plainText]"), required: true, summary: "開ける書類の種類"),
        ],
        code: CodeTemplate(
            call: "DocumentLaunchView",
            trailing:
                " {\n    NewDocumentButton(\"新しいメモ\")\n} onDocumentOpen: { url in\n    Text(url.lastPathComponent)\n}"),
        build: { v in
            AnyView(
                DocumentLaunchView(LocalizedStringKey(v.text("title") ?? ""), for: [.plainText]) {
                    NewDocumentButton("新しいメモ")
                } onDocumentOpen: { url in
                    Text(url.lastPathComponent)
                })
        }
    )
}
