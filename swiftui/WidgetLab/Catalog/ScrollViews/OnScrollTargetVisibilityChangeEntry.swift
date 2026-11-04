import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollTargetVisibilityChange = CatalogEntry(
        id: "onScrollTargetVisibilityChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の止まる目印（scrollTargetLayout の子）のうち、見えているものの id が変わったときに処理を行う modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/onscrolltargetvisibilitychange(idtype:threshold:_:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "onScrollTargetVisibilityChange", id: "onScrollTargetVisibilityChange.idType", label: "idType",
                .fixed(code: "Int.self"), required: true, summary: "子の id の型"),
            .modifier(
                "onScrollTargetVisibilityChange", id: "onScrollTargetVisibilityChange.threshold", label: "threshold",
                .slider(range: 0.1...1, step: 0.1, initial: 0.5), required: true,
                summary: "見えているとする割合（1 なら子の全体が見えているとき）"),
            .modifier(
                "onScrollTargetVisibilityChange", id: "onScrollTargetVisibilityChange.action",
                .fixed(code: "{ visible = $0 }"), on: true, summary: "変わったときの処理（上の行の範囲が変わる）"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    LazyVStack {\n        ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n    }\n"
                + "    .scrollTargetLayout()\n}"),
        build: { v in
            AnyView(
                OnScrollTargetVisibilityChangeDemo(
                    watches: v["onScrollTargetVisibilityChange.action"] != nil,
                    threshold: v.number("onScrollTargetVisibilityChange.threshold") ?? 0.5)
            )
        }
    )
}

private struct OnScrollTargetVisibilityChangeDemo: View {
    let watches: Bool
    let threshold: Double
    @State private var visible: [Int] = []

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(1...30, id: \.self) { i in
                    Text("行 \(i)")
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(.yellow.opacity(0.4))
                }
            }
            .scrollTargetLayout()
        }
        .apply(watches ? () : nil) { view, _ in
            view.onScrollTargetVisibilityChange(idType: Int.self, threshold: threshold) { visible = $0 }
        }
        .safeAreaInset(edge: .top) {
            Text(label)
                .monospacedDigit()
                .padding(6)
                .background(.yellow, in: .capsule)
        }
    }

    private var label: String {
        guard let first = visible.min(), let last = visible.max() else { return "見えている行: なし" }
        return "見えている行: \(first)〜\(last)"
    }
}
