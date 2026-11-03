import SwiftUI

nonisolated extension CatalogEntry {
    static let id = CatalogEntry(
        id: "id",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View の見分けの印（識別子）を決める modifier。値が変わると別の View とみなされ、中の @State も作り直される。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/id(_:)")!,
        stage: .behavior,
        properties: [
            .modifier("id", .fixed(code: "generation"), on: true, summary: "見分けの印。「作り直す」で値を変えると、子の count が 0 に戻る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"作り直す\") { generation += 1 }"], call: "Counter",
            closing: [
                "}",
                "",
                "struct Counter: View {",
                "    @State private var count = 0",
                "",
                "    var body: some View {",
                "        Stepper(\"count: \\(count)\", value: $count)",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(IdDemo.Parent(usesID: v["id"] != nil))
        }
    )
}

private enum IdDemo {
    struct Parent: View {
        let usesID: Bool
        @State private var generation = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Button("作り直す") {
                    generation += 1
                    recorder?.log("generation を \(generation) にした")
                }
                .buttonStyle(.bordered)
                Counter()
                    .apply(usesID ? generation : nil) { $0.id($1) }
            }
        }
    }

    struct Counter: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            Stepper(value: $count) {
                Text("count: \(count)").monospacedDigit()
            }
            .fixedSize()
            .onAppear { recorder?.log("子を作った（count は 0 から）") }
        }
    }
}
