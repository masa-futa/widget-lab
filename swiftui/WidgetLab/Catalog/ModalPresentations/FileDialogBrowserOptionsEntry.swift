import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogBrowserOptions = CatalogEntry(
        id: "fileDialogBrowserOptions",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "ファイルのダイアログで、隠しファイルを出すか・パッケージの中を開けるかなどを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogbrowseroptions(_:)")!,
        noteReason: "iPhone では効かない。Mac のファイルのダイアログで、隠しファイルなどの出し方が変わる",
        properties: [
            .modifier(
                "fileDialogBrowserOptions",
                .choice(
                    [Choice(".includeHiddenFiles"), Choice(".displayFileExtensions"), Choice(".enumeratePackages")],
                    initial: 0), on: true, summary: "ファイルの出し方")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.plainText]"], trailing: " { _ in }")
    )
}
