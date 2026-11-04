import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollVisibilityChange = CatalogEntry(
        id: "onScrollVisibilityChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "View が ScrollView の見える範囲に入った・出たときに、処理を行う modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/onscrollvisibilitychange(threshold:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onScrollVisibilityChange", id: "onScrollVisibilityChange.threshold", label: "threshold",
                .slider(range: 0.1...1, step: 0.1, initial: 0.5), required: true, summary: "見えているとする割合"),
            .modifier(
                "onScrollVisibilityChange", id: "onScrollVisibilityChange.action", .fixed(code: "{ isVisible = $0 }"),
                on: true, summary: "入った・出たときの処理（上の表示が変わる）"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...12, id: \\.self) { Text(\"行 \\($0)\").frame(height: 44) }",
                "    Text(\"目印\")", "        .frame(maxWidth: .infinity, minHeight: 44)",
            ],
            indent: 8, call: ".background", fixedArguments: [".orange"],
            closing: ["    ForEach(13...24, id: \\.self) { Text(\"行 \\($0)\").frame(height: 44) }", "}"]),
        build: { v in
            AnyView(
                OnScrollVisibilityChangeDemo(
                    watches: v["onScrollVisibilityChange.action"] != nil,
                    threshold: v.number("onScrollVisibilityChange.threshold") ?? 0.5)
            )
        }
    )
}

private struct OnScrollVisibilityChangeDemo: View {
    let watches: Bool
    let threshold: Double
    @State private var isVisible: Bool?

    var body: some View {
        ScrollView {
            ForEach(1...12, id: \.self) { Text("行 \($0)").frame(height: 44) }
            Text("目印")
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(.orange)
                .apply(watches ? () : nil) { view, _ in
                    view.onScrollVisibilityChange(threshold: threshold) { isVisible = $0 }
                }
            ForEach(13...24, id: \.self) { Text("行 \($0)").frame(height: 44) }
        }
        .safeAreaInset(edge: .top) {
            Text(label)
                .padding(6)
                .background(.orange.opacity(0.4), in: .capsule)
        }
    }

    private var label: String {
        switch isVisible {
        case true?: "目印: 見えている"
        case false?: "目印: 見えていない"
        case nil: "目印: なし"
        }
    }
}
