import SwiftUI

nonisolated extension CatalogEntry {
    static let fileMover = CatalogEntry(
        id: "fileMover",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、あるファイルを別の場所へ動かすシステムの画面を出す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/filemover(ispresented:file:oncompletion:)")!,
        stage: .card,
        properties: [
            .modifier(
                "fileMover", .fixed(code: "isPresented: $shows, file: memoURL, onCompletion: { result = \"\\($0)\" }"),
                on: true, summary: "出すかどうかの Binding・動かすファイルの URL・動かしたあとに呼ばれる処理")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"メモを動かす\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(FileMoverDemo(moves: v["fileMover"] != nil))
        }
    )
}

private struct FileMoverDemo: View {
    let moves: Bool
    @State private var shows = false
    @State private var file: URL?
    @State private var result = "（まだ動かしていない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("メモを動かす") {
                // 動かすファイルを、押すたびに一時フォルダに作る
                let url = URL.temporaryDirectory.appending(path: "動かすメモ.txt")
                try? "買い物: 牛乳・卵".write(to: url, atomically: true, encoding: .utf8)
                file = url
                shows = true
            }
            .buttonStyle(.borderedProminent)
            .apply(moves ? () : nil) { view, _ in
                view.fileMover(isPresented: $shows, file: file) { outcome in
                    result = (try? outcome.get().lastPathComponent).map { "動かした: \($0)" } ?? "やめた・失敗した"
                }
            }
            Text(result)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
