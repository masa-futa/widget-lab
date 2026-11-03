import SwiftUI

nonisolated extension CatalogEntry {
    static let task = CatalogEntry(
        id: "task",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View が現れる前に、非同期の処理を始める modifier。View が消えると取り消す。id を渡すと、値が変わるたびに取り消してやり直す。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/task(id:name:priority:file:line:_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "task",
                .choice(
                    [
                        Choice("現れたときだけ", code: "{ await load(count) }"),
                        Choice("count が変わるたび", code: "id: count, { await load(count) }"),
                    ],
                    initial: 1),
                on: true, summary: "始める処理と、やり直すきっかけ。load は 1 秒待って終わる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "Text",
            fixedArguments: ["\"count: \\(count)\""], closing: ["}"]),
        build: { v in
            AnyView(TaskDemo(followsCount: v.pick("task", from: [false, true])))
        }
    )
}

private struct TaskDemo: View {
    /// nil なら task をかけない。true なら count が変わるたびにやり直す
    let followsCount: Bool?
    @State private var count = 0
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
                .controlSize(.large)
            label
        }
    }

    @ViewBuilder
    private var label: some View {
        let text = Text("count: \(count)").monospacedDigit()
        switch followsCount {
        case nil: text
        case false?: text.task { await load(count) }
        case true?: text.task(id: count) { await load(count) }
        }
    }

    private func load(_ count: Int) async {
        recorder?.log("count \(count) の読み込みを始めた")
        do {
            try await Task.sleep(for: .seconds(1))
            recorder?.log("count \(count) の読み込みが終わった")
        } catch {
            recorder?.log("count \(count) の読み込みを取り消した")
        }
    }
}
