import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationBackgroundInteraction = CatalogEntry(
        id: "presentationBackgroundInteraction",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートを出している間も、後ろの画面を触れるようにするかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/presentationbackgroundinteraction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationBackgroundInteraction",
                .choice(
                    [
                        Choice(".automatic"), Choice(".enabled"), Choice(".enabled(upThrough: .height(200))"),
                        Choice(".disabled"),
                    ], initial: 1), on: true,
                summary: "後ろを触れるか。upThrough はその高さまで下がっているときだけ触れる")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {", "    Button(\"+1: \\(count)\") { count += 1 }",
                "    Button(\"シートを開く\") { shows = true }", "        .sheet(isPresented: $shows) {",
            ], indent: 12, call: "Text", fixedArguments: ["\"シートの中身\""],
            suffix: [".presentationDetents([.height(200), .large])"], closing: ["        }", "}"]),
        build: { v in
            AnyView(
                PresentationBackgroundInteractionDemo(
                    interaction: v.pick(
                        "presentationBackgroundInteraction",
                        from: [
                            PresentationBackgroundInteraction.automatic, .enabled, .enabled(upThrough: .height(200)),
                            .disabled,
                        ])))
        }
    )
}

private struct PresentationBackgroundInteractionDemo: View {
    let interaction: PresentationBackgroundInteraction?
    @State private var count = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("+1: \(count)") { count += 1 }
                .buttonStyle(.bordered)
                .monospacedDigit()
            SheetModifierDemo {
                ModalSheetContent("シートの中身")
                    .apply(interaction) { $0.presentationBackgroundInteraction($1) }
                    .presentationDetents([.height(200), .large])
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 24)
    }
}
