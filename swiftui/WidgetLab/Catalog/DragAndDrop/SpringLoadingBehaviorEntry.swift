import SwiftUI

nonisolated extension CatalogEntry {
    static let springLoadingBehavior = CatalogEntry(
        id: "springLoadingBehavior",
        kind: .modifier,
        topic: .dragAndDrop,
        summary: "ドラッグしたまま上で少し待つと、ボタンなどが押される（スプリングロード）かを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/springloadingbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "springLoadingBehavior",
                .choice([Choice(".enabled"), Choice(".disabled"), Choice(".automatic")], initial: 0), on: true,
                summary: ".enabled なら、札を引いたままボタンの上で待つと押される。付けない（.automatic）と、このボタンは押されない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"りんご\")", "        .draggable(\"りんご\")"], indent: 4, call: "Button",
            fixedArguments: ["\"開いた回数: \\(count)\""], trailing: " { count += 1 }", closing: ["}"]),
        build: { v in
            AnyView(
                SpringLoadingBehaviorDemo(
                    behavior: v.pick(
                        "springLoadingBehavior", from: [SpringLoadingBehavior.enabled, .disabled, .automatic])
                ))
        }
    )
}

private struct SpringLoadingBehaviorDemo: View {
    /// nil なら springLoadingBehavior を付けない
    let behavior: SpringLoadingBehavior?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 24) {
            DragChip(text: "りんご")
                .draggable("りんご")
            Button("開いた回数: \(count)") { count += 1 }
                .buttonStyle(.bordered)
                .apply(behavior) { $0.springLoadingBehavior($1) }
        }
    }
}
