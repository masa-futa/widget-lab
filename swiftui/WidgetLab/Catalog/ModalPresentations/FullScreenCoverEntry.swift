import SwiftUI

nonisolated extension CatalogEntry {
    static let fullScreenCover = CatalogEntry(
        id: "fullScreenCover",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、画面をできるだけ覆う View を重ねて出す modifier。指で下げても閉じない。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "fullScreenCover",
                .choice(
                    [
                        Choice("isPresented", code: "isPresented: $shows, content: { CoverContent() }"),
                        Choice(
                            "onDismiss も渡す",
                            code: "isPresented: $shows, onDismiss: { closed += 1 }, content: { CoverContent() }"),
                    ], initial: 0), on: true,
                summary: "出すかどうかの Binding と中身。中身には閉じるボタンを置く（dismiss を呼ぶ）")
        ],
        code: CodeTemplate(
            call: "Button", fixedArguments: ["\"全画面で開く\""], trailing: " { shows = true }",
            closing: [
                "",
                "struct CoverContent: View {",
                "    @Environment(\\.dismiss) private var dismiss",
                "",
                "    var body: some View {",
                "        Button(\"閉じる\") { dismiss() }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                FullScreenCoverDemo(
                    kind: v.pick("fullScreenCover", from: [FullScreenCoverDemo.Kind.plain, .onDismiss])))
        }
    )
}

private struct FullScreenCoverDemo: View {
    enum Kind {
        case plain, onDismiss
    }

    let kind: Kind?
    @State private var shows = false
    @State private var closed = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("全画面で開く") { shows = true }
                .buttonStyle(.borderedProminent)
                .apply(kind) { view, kind in
                    switch kind {
                    case .plain:
                        view.fullScreenCover(isPresented: $shows) { ModalSheetContent("全画面のカバー") }
                    case .onDismiss:
                        view.fullScreenCover(isPresented: $shows, onDismiss: { closed += 1 }) {
                            ModalSheetContent("全画面のカバー")
                        }
                    }
                }
            Text("閉じた回数: \(closed)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
