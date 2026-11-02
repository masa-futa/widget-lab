import SwiftUI

nonisolated extension CatalogEntry {
    static let state = CatalogEntry(
        id: "State",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "View が持つ値。値が変わると、その値を使う View が描き直される。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/state")!,
        stage: .behavior,
        properties: [
            .wrapper("State", summary: "外すと、値は変わっても SwiftUI が見張らないので、表示が描き直されない。描き直しの回数は、SwiftUI の都合で 1〜2 回ずれることがある")
        ],
        code: CodeTemplate(
            call: "State",
            wrapper: WrapperCode(
                withWrapper: [
                    "@State private var count = 0",
                    "",
                    "var body: some View {",
                    "    Button(\"+1\") { count += 1 }",
                    "    Text(\"count: \\(count)\")",
                    "}",
                ],
                withoutWrapper: [
                    "private let box = Box()  // SwiftUI が見張らない参照型",
                    "",
                    "var body: some View {",
                    "    Button(\"+1\") { box.count += 1 }",
                    "    Text(\"count: \\(box.count)\")",
                    "}",
                    "",
                    "final class Box { var count = 0 }",
                ])),
        build: { v in
            v["State"] != nil ? AnyView(StateDemo.WithState()) : AnyView(StateDemo.WithoutState())
        }
    )
}

private enum StateDemo {
    struct WithState: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "見本")
            VStack(spacing: 8) {
                Button("+1") {
                    count += 1
                    recorder?.log("count を \(count) にした")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Text("count: \(count)")
                    .monospacedDigit()
            }
        }
    }

    /// SwiftUI が見張らない参照型
    final class Box {
        var count = 0
    }

    struct WithoutState: View {
        // プレビュー（PreviewArea）が記録を読まないので、見本を作り直すまで同じ箱が残る
        private let box = Box()
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "見本")
            VStack(spacing: 8) {
                Button("+1") {
                    box.count += 1
                    recorder?.log("count を \(box.count) にした（表示は変わらない）")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                Text("count: \(box.count)")
                    .monospacedDigit()
            }
        }
    }
}
