import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogConfirmationLabel = CatalogEntry(
        id: "fileDialogConfirmationLabel",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログの、決めるボタンの文を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogconfirmationlabel(_:)")!,
        noteReason: "iPhone では見た目が変わらない。Mac のファイルのダイアログで、決めるボタンの文が変わる",
        properties: [
            .modifier("fileDialogConfirmationLabel", .text(initial: "読み込む"), on: true, summary: "決めるボタンの文")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
