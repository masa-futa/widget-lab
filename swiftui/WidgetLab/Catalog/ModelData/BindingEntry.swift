import SwiftUI

nonisolated extension CatalogEntry {
    static let binding = CatalogEntry(
        id: "Binding",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "ほかの View が持つ値を読み書きする参照。子の View から親の値を変えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/binding")!,
        stage: .behavior,
        properties: [
            .wrapper("Binding", summary: "外して値のコピーを持つと、子で変えても親に届かない。描き直しの回数は、SwiftUI の都合で 1〜2 回ずれることがある")
        ],
        code: CodeTemplate(
            call: "Binding",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@State private var count = 0",
                    "var body: some View {",
                    "    Text(\"親: \\(count)\")",
                    "    Child(count: $count)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@Binding var count: Int",
                    "var body: some View {",
                    "    Stepper(\"子: \\(count)\", value: $count)",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "@State private var count = 0",
                    "var body: some View {",
                    "    Text(\"親: \\(count)\")",
                    "    Child(count: count)",
                    "}",
                    "",
                    "// 子（Child）",
                    "@State var count: Int  // 親の値のコピー",
                    "var body: some View {",
                    "    Stepper(\"子: \\(count)\", value: $count)",
                    "}",
                ])),
        build: { v in
            AnyView(BindingDemo.Parent(usesBinding: v["Binding"] != nil))
        }
    )
}

private enum BindingDemo {
    struct Parent: View {
        let usesBinding: Bool
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Text("親: \(count)")
                    .monospacedDigit()
                if usesBinding {
                    BoundChild(count: $count)
                } else {
                    CopiedChild(count: count)
                }
            }
        }
    }

    struct BoundChild: View {
        @Binding var count: Int
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            ChildStepper(count: $count)
                .onChange(of: count) { recorder?.log("子で count を \(count) にした") }
        }
    }

    struct CopiedChild: View {
        /// 親の値のコピー
        @State var count: Int
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            ChildStepper(count: $count)
                .onChange(of: count) { recorder?.log("子で count を \(count) にした（親には届かない）") }
        }
    }

    struct ChildStepper: View {
        @Binding var count: Int

        var body: some View {
            // 文字が大きくて半分の幅に入らないときは、ラベルを上に置く
            ViewThatFits(in: .horizontal) {
                Stepper(value: $count) { label }
                    .fixedSize()
                VStack(spacing: 4) {
                    label
                    Stepper(value: $count) { label }
                        .labelsHidden()
                }
            }
        }

        private var label: some View {
            Text("子: \(count)").monospacedDigit()
        }
    }
}
