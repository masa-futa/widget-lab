import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationCompactAdaptation = CatalogEntry(
        id: "presentationCompactAdaptation",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "幅や高さが狭いとき（iPhone など）に、吹き出しやシートをどの出し方に変えるかを決める modifier。中身にかける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/presentationcompactadaptation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "presentationCompactAdaptation",
                .choice(
                    [
                        Choice(".automatic"), Choice(".popover"), Choice(".sheet"), Choice(".fullScreenCover"),
                        Choice(".none"),
                    ], initial: 1), on: true,
                summary: "狭いときの出し方。.automatic なら、吹き出しはシートに変わる")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"吹き出しを出す\") { shows = true }", "    .popover(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"吹き出しの中身\""], closing: ["    }"]),
        build: { v in
            AnyView(
                PresentationCompactAdaptationDemo(
                    adaptation: v.pick(
                        "presentationCompactAdaptation",
                        from: [PresentationAdaptation.automatic, .popover, .sheet, .fullScreenCover, .none])))
        }
    )
}

private struct PresentationCompactAdaptationDemo: View {
    let adaptation: PresentationAdaptation?
    @State private var shows = false

    var body: some View {
        Button("吹き出しを出す") { shows = true }
            .buttonStyle(.borderedProminent)
            .popover(isPresented: $shows) {
                ModalSheetContent("吹き出しの中身")
                    .frame(idealWidth: 240, idealHeight: 160)
                    .apply(adaptation) { $0.presentationCompactAdaptation($1) }
            }
    }
}
