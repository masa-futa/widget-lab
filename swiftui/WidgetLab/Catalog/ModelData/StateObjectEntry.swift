import SwiftUI

nonisolated extension CatalogEntry {
    static let stateObject = CatalogEntry(
        id: "StateObject",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "View が作って持ち続ける ObservableObject。親が描き直しても作り直さず、中身が変わると描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/stateobject")!,
        stage: .behavior,
        properties: [
            .wrapper("StateObject", summary: "@ObservedObject にすると、親が描き直すたびに Counter を作り直し、数が 0 に戻る")
        ],
        code: CodeTemplate(
            call: "StateObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var redraws = 0",
                    "var body: some View {",
                    "    Button(\"親を描き直す: \\(redraws)\") { redraws += 1 }",
                    "    Child()",
                    "}",
                    "",
                    "// 子（Child）",
                    "@StateObject private var counter = Counter()",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var redraws = 0",
                    "var body: some View {",
                    "    Button(\"親を描き直す: \\(redraws)\") { redraws += 1 }",
                    "    Child()",
                    "}",
                    "",
                    "// 子（Child）",
                    "@ObservedObject private var counter = Counter()  // 親が描き直すたびに作り直す",
                    "var body: some View {",
                    "    Button(\"子: \\(counter.count)\") { counter.count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(StateObjectDemo.Parent(ownsObject: v["StateObject"] != nil))
        }
    )
}

private enum StateObjectDemo {
    struct Parent: View {
        let ownsObject: Bool
        @State private var redraws = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                CounterRow(title: "親を描き直す", count: redraws) {
                    redraws += 1
                    recorder?.log("親を描き直した")
                }
                if ownsObject {
                    OwningChild()
                } else {
                    ObservingChild()
                }
            }
        }
    }

    struct OwningChild: View {
        @StateObject private var counter = DemoCounter()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("子の count を \(counter.count) にした")
            }
        }
    }

    struct ObservingChild: View {
        /// 親が描き直すたびに作り直す
        @ObservedObject private var counter = DemoCounter()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "子", count: counter.count) {
                counter.count += 1
                recorder?.log("子の count を \(counter.count) にした")
            }
        }
    }
}
