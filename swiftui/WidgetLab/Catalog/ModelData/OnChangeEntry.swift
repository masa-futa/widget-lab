import SwiftUI

nonisolated extension CatalogEntry {
    static let onChange = CatalogEntry(
        id: "onChange",
        kind: .modifier,
        topic: .modelData,
        summary: "見張る値が変わったときに、処理を行う modifier。処理には前の値と新しい値が渡る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onchange(of:initial:_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onChange", id: "onChange.of", label: "of", .fixed(code: "count"), required: true,
                summary: "見張る値（Equatable）"),
            .modifier(
                "onChange", id: "onChange.initial", label: "initial", .toggle(initial: false), required: true,
                summary: "true なら、現れたときにも 1 回行う"),
            .modifier(
                "onChange", id: "onChange.action", label: nil,
                .fixed(code: "{ oldValue, newValue in print(\"\\(oldValue) → \\(newValue)\") }"), on: true,
                summary: "変わったときの処理。+1 を押すたびに記録に出る"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "Text",
            fixedArguments: ["\"count: \\(count)\""], closing: ["}"]),
        build: { v in
            AnyView(
                OnChangeDemo(
                    watches: v["onChange.action"] != nil, initial: v.flag("onChange.initial") ?? false))
        }
    )
}

private struct OnChangeDemo: View {
    let watches: Bool
    let initial: Bool
    @State private var count = 0
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
                .controlSize(.large)
            Text("count: \(count)")
                .monospacedDigit()
                .apply(watches ? () : nil) { view, _ in
                    view.onChange(of: count, initial: initial) { oldValue, newValue in
                        recorder?.log("count が \(oldValue) → \(newValue)")
                    }
                }
        }
    }
}
