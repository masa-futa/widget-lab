import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogImportsUnresolvedAliases = CatalogEntry(
        id: "fileDialogImportsUnresolvedAliases",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログでエイリアスを選んだとき、指す先でなくエイリアスそのものを渡すかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/filedialogimportsunresolvedaliases(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、エイリアス（別名）を選んだときに効く",
        properties: [
            .modifier(
                "fileDialogImportsUnresolvedAliases", .toggle(initial: true), on: true, summary: "true ならエイリアスそのものを渡す")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
