import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let fileExporter = CatalogEntry(
        id: "fileExporter",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、データをファイルに書き出す場所を選ぶシステムの画面を出す modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/fileexporter(ispresented:item:contenttypes:defaultfilename:oncompletion:oncancellation:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "fileExporter", id: "fileExporter.isPresented", label: "isPresented", .fixed(code: "$shows"),
                required: true, summary: "出すかどうかの Binding"),
            .modifier(
                "fileExporter", id: "fileExporter.item", label: "item", .fixed(code: "\"買い物: 牛乳・卵\""),
                required: true, summary: "書き出すもの（Transferable。ここでは文字）"),
            .modifier(
                "fileExporter", id: "fileExporter.contentTypes", label: "contentTypes", .fixed(code: "[.plainText]"),
                on: true, summary: "書き出すファイルの種類"),
            .modifier(
                "fileExporter", id: "fileExporter.defaultFilename", label: "defaultFilename",
                .text(initial: "買い物メモ"), on: true, summary: "最初に入っているファイルの名前"),
            .modifier(
                "fileExporter", id: "fileExporter.onCompletion", label: "onCompletion",
                .fixed(code: "{ result = \"\\($0)\" }"), required: true, summary: "書き出したあと（失敗も）に呼ばれる"),
            .modifier(
                "fileExporter", id: "fileExporter.onCancellation", label: "onCancellation",
                .fixed(code: "{ result = \"やめた\" }"), required: true, summary: "やめたときに呼ばれる"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"書き出す\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(
                FileExporterDemo(
                    exports: v["fileExporter.contentTypes"] != nil || v["fileExporter.defaultFilename"] != nil,
                    types: v["fileExporter.contentTypes"] != nil ? [.plainText] : [],
                    filename: v.text("fileExporter.defaultFilename")))
        }
    )
}

private struct FileExporterDemo: View {
    let exports: Bool
    let types: [UTType]
    let filename: String?
    @State private var shows = false
    @State private var result = "（まだ書き出していない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("書き出す") { shows = true }
                .buttonStyle(.borderedProminent)
                // required でない引数（contentTypes・defaultFilename）がどれも OFF なら、modifier ごと付けない
                .apply(exports ? () : nil) { view, _ in
                    view.fileExporter(
                        isPresented: $shows, item: "買い物: 牛乳・卵", contentTypes: types, defaultFilename: filename
                    ) { outcome in
                        result = (try? outcome.get().lastPathComponent).map { "書き出した: \($0)" } ?? "失敗した"
                    } onCancellation: {
                        result = "やめた"
                    }
                }
            Text(result)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
