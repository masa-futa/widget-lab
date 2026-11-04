import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogURLEnabled = CatalogEntry(
        id: "fileDialogURLEnabled",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログで、条件に合うファイルだけを選べるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogurlenabled(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、条件に合わないファイルが選べなくなる",
        properties: [
            .modifier(
                "fileDialogURLEnabled", .fixed(code: "#Predicate<URL> { $0.lastPathComponent.hasPrefix(\"メモ\") }"),
                on: true, summary: "選べるファイルの条件")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
