import SwiftUI

nonisolated extension CatalogEntry {
    static let equatable = CatalogEntry(
        id: "equatable",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View を == で前の値と比べ、同じなら中を描き直さないようにする modifier。View が Equatable に準拠しているときに使える。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/equatable()")!,
        stage: .behavior,
        properties: [
            .modifier("equatable", .fixed(code: ""), on: true, summary: "付けると、子の == が true の間（5 ごとに切り替わるまで）、子を描き直さない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "Child",
            fixedArguments: ["count: count"],
            closing: [
                "}",
                "",
                "struct Child: View, Equatable {",
                "    let count: Int",
                "",
                "    // 5 ごとにだけ違うとみなす",
                "    static func == (a: Self, b: Self) -> Bool { a.count / 5 == b.count / 5 }",
                "",
                "    var body: some View {",
                "        Text(\"\\(count / 5 * 5) 台\")",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(EquatableDemo.Parent(usesEquatable: v["equatable"] != nil))
        }
    )
}

private enum EquatableDemo {
    struct Parent: View {
        let usesEquatable: Bool
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Button("+1") {
                    count += 1
                    recorder?.log("count を \(count) にした")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                if usesEquatable {
                    Child(count: count).equatable()
                } else {
                    Child(count: count)
                }
            }
        }
    }

    struct Child: View, Equatable {
        let count: Int
        @Environment(\.demoRecorder) private var recorder

        nonisolated static func == (a: Self, b: Self) -> Bool { a.count / 5 == b.count / 5 }

        var body: some View {
            let _ = reportBody(recorder, "子")
            Text("\(count / 5 * 5) 台")
                .monospacedDigit()
        }
    }
}
