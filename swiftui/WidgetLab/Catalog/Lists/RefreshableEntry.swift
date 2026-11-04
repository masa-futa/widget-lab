import SwiftUI

nonisolated extension CatalogEntry {
    static let refreshable = CatalogEntry(
        id: "refreshable",
        kind: .modifier,
        topic: .lists,
        summary: "下に引っ張って更新する操作を足し、そのときに行う非同期の処理を渡す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/refreshable(action:)")!,
        stage: .card,
        properties: [
            .modifier(
                "refreshable", label: "action", .fixed(code: "{ await reload() }"), on: true,
                summary: "更新の処理（一覧を下に引っ張ると、終わるまで回る印が出る）")
        ],
        code: CodeTemplate(
            call: "List",
            trailing: " {\n    Text(\"更新した回数: \\(count)\")\n    Text(\"下に引っ張る\")\n}"),
        build: { v in
            AnyView(RefreshableDemo(refreshes: v["refreshable"] != nil))
        }
    )
}

private struct RefreshableDemo: View {
    let refreshes: Bool
    @State private var count = 0

    var body: some View {
        List {
            Text("更新した回数: \(count)")
            Text("下に引っ張る")
        }
        .apply(refreshes ? () : nil) { view, _ in
            view.refreshable {
                try? await Task.sleep(for: .seconds(1))
                count += 1
            }
        }
    }
}
