import SwiftUI

nonisolated extension CatalogEntry {
    static let fileDialogDefaultDirectory = CatalogEntry(
        id: "fileDialogDefaultDirectory",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "fileExporter・fileImporter・fileMover の画面を、はじめに開くフォルダを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/filedialogdefaultdirectory(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fileDialogDefaultDirectory", .fixed(code: "URL.documentsDirectory"), on: true,
                summary: "はじめに開くフォルダ")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"ファイルを選ぶ\") { shows = true }"], indent: 4, call: ".fileImporter",
            fixedArguments: ["isPresented: $shows", "allowedContentTypes: [.item]"], trailing: " { _ in }"),
        build: { v in
            AnyView(
                FileDialogDefaultDirectoryDemo(
                    directory: v["fileDialogDefaultDirectory"] != nil ? URL.documentsDirectory : nil))
        }
    )
}

private struct FileDialogDefaultDirectoryDemo: View {
    let directory: URL?
    @State private var shows = false

    var body: some View {
        Button("ファイルを選ぶ") { shows = true }
            .buttonStyle(.borderedProminent)
            .fileImporter(isPresented: $shows, allowedContentTypes: [.item]) { _ in }
            .apply(directory) { $0.fileDialogDefaultDirectory($1) }
    }
}
