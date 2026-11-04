import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogMessage = CatalogEntry(
        id: "fileDialogMessage",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログの上に、題名のような説明の文を出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogmessage(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac のファイルのダイアログで、上に説明の文が出る",
        properties: [
            .modifier("fileDialogMessage", .fixed(code: "Text(\"読み込むメモを選んでください\")"), on: true, summary: "上に出す説明の文")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
