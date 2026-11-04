import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollGeometryChange = CatalogEntry(
        id: "onScrollGeometryChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の大きさや位置（ScrollGeometry）から取り出した値が変わったときに、処理を行う modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/onscrollgeometrychange(for:of:action:)")!,
        stage: .card,
        properties: [
            .modifier(
                "onScrollGeometryChange", id: "onScrollGeometryChange.for", label: "for", .fixed(code: "CGFloat.self"),
                required: true, summary: "取り出す値の型"),
            .modifier(
                "onScrollGeometryChange", id: "onScrollGeometryChange.of", label: "of",
                .choice(
                    [
                        Choice("ずらした量", code: "{ $0.contentOffset.y + $0.contentInsets.top }"),
                        Choice("visibleRect.maxY", code: "{ $0.visibleRect.maxY }"),
                        Choice("contentSize.height", code: "{ $0.contentSize.height }"),
                    ],
                    initial: 0),
                required: true, summary: "取り出す値（ずらした量・見えている下端・中身の高さ）"),
            .modifier(
                "onScrollGeometryChange", id: "onScrollGeometryChange.action", label: "action",
                .fixed(code: "{ value = $1 }"), on: true, summary: "変わったときの処理（上の数が変わる）"),
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                OnScrollGeometryChangeDemo(
                    watches: v["onScrollGeometryChange.action"] != nil,
                    kind: v.pick("onScrollGeometryChange.of", from: [0, 1, 2]) ?? 0)
            )
        }
    )
}

private struct OnScrollGeometryChangeDemo: View {
    let watches: Bool
    let kind: Int
    @State private var value: CGFloat?

    var body: some View {
        ScrollView {
            ForEach(1...30, id: \.self) { i in
                Text("行 \(i)")
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
        }
        .apply(watches ? () : nil) { view, _ in
            view.onScrollGeometryChange(for: CGFloat.self) { geometry in
                switch kind {
                case 0: geometry.contentOffset.y + geometry.contentInsets.top
                case 1: geometry.visibleRect.maxY
                default: geometry.contentSize.height
                }
            } action: { _, new in
                value = new
            }
        }
        .safeAreaInset(edge: .top) {
            Text("value: \(value.map { "\(Int($0))" } ?? "なし")")
                .monospacedDigit()
                .padding(6)
                .background(.yellow, in: .capsule)
        }
    }
}
