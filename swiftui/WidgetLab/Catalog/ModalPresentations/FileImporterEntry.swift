import SwiftUI
import UniformTypeIdentifiers

nonisolated extension CatalogEntry {
    static let fileImporter = CatalogEntry(
        id: "fileImporter",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、読み込むファイルを選ぶシステムの画面を出す modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/fileimporter(ispresented:allowedcontenttypes:allowsmultipleselection:oncompletion:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "fileImporter", id: "fileImporter.isPresented", label: "isPresented", .fixed(code: "$shows"),
                required: true, summary: "出すかどうかの Binding"),
            .modifier(
                "fileImporter", id: "fileImporter.allowedContentTypes", label: "allowedContentTypes",
                .choice([Choice("[.item]"), Choice("[.image]"), Choice("[.plainText, .pdf]")], initial: 1),
                required: true,
                summary: "選べるファイルの種類。ほかの種類は薄く出て選べない"),
            .modifier(
                "fileImporter", id: "fileImporter.allowsMultipleSelection", label: "allowsMultipleSelection",
                .toggle(initial: true), on: true, summary: "true なら複数を選べる"),
            .modifier(
                "fileImporter", id: "fileImporter.onCompletion", label: "onCompletion",
                .fixed(code: "{ result = \"\\($0)\" }"), required: true, summary: "選んだあと（やめたときも）に呼ばれる"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"ファイルを選ぶ\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(
                FileImporterDemo(
                    types: v.pick(
                        "fileImporter.allowedContentTypes", from: [[UTType.item], [.image], [.plainText, .pdf]]),
                    multiple: v.flag("fileImporter.allowsMultipleSelection")))
        }
    )
}

private struct FileImporterDemo: View {
    let types: [UTType]?
    let multiple: Bool?
    @State private var shows = false
    @State private var result = "（まだ選んでいない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("ファイルを選ぶ") { shows = true }
                .buttonStyle(.borderedProminent)
                // required でない引数（allowsMultipleSelection）が OFF なら、modifier ごと付けない
                .apply(types.flatMap { t in multiple.map { (t, $0) } }) { view, args in
                    view.fileImporter(
                        isPresented: $shows, allowedContentTypes: args.0,
                        allowsMultipleSelection: args.1
                    ) { outcome in
                        result = (try? outcome.get()).map { "選んだ: \($0.count) 件" } ?? "やめた・失敗した"
                    }
                }
            Text(result)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
