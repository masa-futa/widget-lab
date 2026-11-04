import SwiftUI

nonisolated extension CatalogEntry {
    static let observedObject = CatalogEntry(
        id: "ObservedObject",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "親から受け取った ObservableObject を見張る。中身が変わると、受け取った View を描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/observedobject")!,
        stage: .behavior,
        properties: [
            .wrapper("ObservedObject", summary: "外すと、子で数を増やしても、子は描き直されず表示が変わらない")
        ],
        code: CodeTemplate(
            call: "ObservedObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var counter = Counter()  // 持つだけで見張らない",
                    "var body: some View {",
                    "    Child(counter: counter)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@ObservedObject var counter: Counter",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var counter = Counter()  // 持つだけで見張らない",
                    "var body: some View {",
                    "    Child(counter: counter)",
                    "}",
                    "",
                    "// 子（Child）",
                    "let counter: Counter  // 見張らない",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(ObservedObjectDemo.Parent(observes: v["ObservedObject"] != nil))
        }
    )
}

private enum ObservedObjectDemo {
    struct Parent: View {
        let observes: Bool
        /// 持つだけで見張らない（ObservableObject の中身が変わっても、親は描き直さない）
        @State private var counter = DemoCounter()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            if observes {
                ObservingChild(counter: counter)
            } else {
                PlainChild(counter: counter)
            }
        }
    }

    struct ObservingChild: View {
        @ObservedObject var counter: DemoCounter
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("count を \(counter.count) にした")
            }
        }
    }

    struct PlainChild: View {
        /// 見張らない
        let counter: DemoCounter
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("count を \(counter.count) にした（表示は変わらない）")
            }
        }
    }
}
