import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilitySortPriority = CatalogEntry(
        id: "accessibilitySortPriority",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "同じ入れ物の中で、要素を読む順を決める modifier。数が大きいものから読む（既定は 0）。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitysortpriority(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilitySortPriority", .slider(range: -1...2, step: 1, initial: 1), on: true,
                summary: "読む順の重み。値段に 1 を付けると、名前より先に読む")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"りんご\")"], call: "Text", fixedArguments: ["\"200 円\""],
            closing: ["    Text(\"青森\")", "}", ".accessibilityElement(children: .contain)"]),
        build: { v in
            AnyView(SortPriorityDemo(priority: v.number("accessibilitySortPriority")))
        }
    )
}

private struct SortPriorityDemo: View {
    /// nil なら modifier をかけない
    let priority: Double?

    var body: some View {
        A11yDemo(title: "VoiceOver が順に読む要素", lines: A11yText.ordered(order.map { A11yText.element($0) })) {
            VStack(spacing: 4) {
                Text("りんご")
                    .font(.title3)
                Text("200 円")
                    .font(.headline)
                    .apply(priority) { view, priority in
                        view.accessibilitySortPriority(priority)
                    }
                Text("青森")
                    .font(.caption)
            }
            .accessibilityElement(children: .contain)
        }
    }

    /// 重みの大きい順。同じ重みなら上から
    private var order: [String] {
        let items = [("りんご", 0.0), ("200 円", priority ?? 0), ("青森", 0)]
        return items.enumerated().sorted { a, b in
            a.element.1 != b.element.1 ? a.element.1 > b.element.1 : a.offset < b.offset
        }.map(\.element.0)
    }
}
