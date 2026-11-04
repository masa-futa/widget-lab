import SwiftUI

nonisolated extension CatalogEntry {
    static let speechAnnouncementsQueued = CatalogEntry(
        id: "speechAnnouncementsQueued",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "ラベルや値が変わったときの読み上げを、今の読み上げのあとに並べる modifier。付けないと、今の読み上げを止めて読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/speechannouncementsqueued(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechAnnouncementsQueued", .toggle(initial: true), on: true,
                summary: "true なら、今の読み上げのあとに並べる")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"進める\") { progress += 25 }"], call: "Text",
            fixedArguments: ["\"ダウンロード \\(progress)%\""], closing: ["}"]),
        build: { v in
            AnyView(AnnouncementsQueuedDemo(queued: v.flag("speechAnnouncementsQueued")))
        }
    )
}

private struct AnnouncementsQueuedDemo: View {
    /// nil なら modifier をかけない
    let queued: Bool?
    @State private var progress = 25

    var body: some View {
        A11yDemo(
            title: "値が変わったときの読み上げ",
            lines: [queued == true ? "今の読み上げのあとに読む" : "今の読み上げを止めて、すぐに読む"]
        ) {
            VStack(spacing: 8) {
                Button("進める") { progress = progress >= 100 ? 0 : progress + 25 }
                    .buttonStyle(.bordered)
                Text("ダウンロード \(progress)%")
                    .monospacedDigit()
                    .apply(queued) { view, queued in
                        view.speechAnnouncementsQueued(queued)
                    }
            }
        }
    }
}
