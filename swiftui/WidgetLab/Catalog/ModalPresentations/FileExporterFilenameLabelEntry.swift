import SwiftUI

nonisolated extension CatalogEntry {
    static let fileExporterFilenameLabel = CatalogEntry(
        id: "fileExporterFilenameLabel",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "fileExporter の画面の、ファイルの名前の欄に付ける見出しを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fileexporterfilenamelabel(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac の保存のダイアログで、名前の欄の見出しが変わる",
        properties: [
            .modifier("fileExporterFilenameLabel", .fixed(code: "Text(\"メモの名前\")"), on: true, summary: "名前の欄の見出し")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"書き出す\") { shows = true }"], indent: 4, call: ".fileExporter",
            fixedArguments: ["isPresented: $shows", "item: memo", "contentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
