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
                "// nonisolated にしないと、既定の分離が MainActor のとき == が SwiftUI から使われない",
                "nonisolated struct Child: View, Equatable {",
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
            let _ = EquatableDemo.recorders[usesEquatable] = recorder
            VStack(spacing: 8) {
                Button("+1") {
                    count += 1
                    recorder?.log("count を \(count) にした")
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                if usesEquatable {
                    Child(count: count, usesEquatable: true).equatable()
                } else {
                    Child(count: count, usesEquatable: false)
                }
            }
        }
    }

    /// 子に渡す記録の窓口（付けた側か → 窓口）。親の body で入れる
    static var recorders: [Bool: any DemoRecorder] = [:]

    /// nonisolated にする（既定の MainActor のままだと Equatable への準拠も MainActor に閉じ、SwiftUI が == を使わない）。
    /// 値の型のプロパティだけを持たせ、記録の窓口は親から引く（Environment を読むと、環境の書き直しで == と関係なく
    /// 描き直され、違いが見えなくなるおそれがあるため）
    nonisolated struct Child: View, Equatable {
        let count: Int
        /// 記録の窓口を引く鍵（付けた側か）
        let usesEquatable: Bool

        static func == (a: Self, b: Self) -> Bool { a.count / 5 == b.count / 5 }

        var body: some View {
            let _ = reportBody(EquatableDemo.recorders[usesEquatable], "子")
            Text("\(count / 5 * 5) 台")
                .monospacedDigit()
        }
    }
}
