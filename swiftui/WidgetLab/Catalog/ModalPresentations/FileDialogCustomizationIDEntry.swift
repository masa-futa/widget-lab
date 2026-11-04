import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogCustomizationID = CatalogEntry(
        id: "fileDialogCustomizationID",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログの大きさや開いていたフォルダを、id ごとに覚えて次に戻す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogcustomizationid(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、大きさや開いていたフォルダを覚える",
        properties: [
            .modifier("fileDialogCustomizationID", .text(initial: "memoImport"), on: true, summary: "覚えておく単位の id")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
