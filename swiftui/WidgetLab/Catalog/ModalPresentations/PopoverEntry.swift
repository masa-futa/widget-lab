import SwiftUI

nonisolated extension CatalogEntry {
    static let popover = CatalogEntry(
        id: "popover",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、押した View から吹き出しのように出す modifier。iPhone では、ふつうはシートに変わる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/popover(ispresented:attachmentanchor:arrowedge:content:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "popover",
                .choice(
                    [
                        Choice("isPresented", code: "isPresented: $shows, content: { PopoverContent() }"),
                        Choice(
                            "arrowEdge: .top",
                            code: "isPresented: $shows, arrowEdge: .top, content: { PopoverContent() }"),
                        Choice(
                            "arrowEdge: .bottom",
                            code: "isPresented: $shows, arrowEdge: .bottom, content: { PopoverContent() }"),
                    ], initial: 0), on: true,
                summary: "出すかどうかの Binding と中身。arrowEdge は矢印を向ける向き（収まらなければ変わる）")
        ],
        code: CodeTemplate(
            call: "Button", fixedArguments: ["\"吹き出しを出す\""], trailing: " { shows = true }",
            closing: [
                "",
                "struct PopoverContent: View {",
                "    var body: some View {",
                "        Text(\"吹き出しの中身\")",
                "            .padding()",
                "            // iPhone でも吹き出しのまま出す",
                "            .presentationCompactAdaptation(.popover)",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(PopoverDemo(edge: v.pick("popover", from: [Edge?.none, .top, .bottom])))
        }
    )
}

private struct PopoverDemo: View {
    /// nil の nil なら OFF、中の nil なら arrowEdge を渡さない
    let edge: Edge??
    @State private var shows = false

    var body: some View {
        Button("吹き出しを出す") { shows = true }
            .buttonStyle(.borderedProminent)
            .apply(edge) { view, edge in
                if let edge {
                    view.popover(isPresented: $shows, arrowEdge: edge) { content }
                } else {
                    view.popover(isPresented: $shows) { content }
                }
            }
    }

    private var content: some View {
        Text("吹き出しの中身")
            .padding()
            .presentationCompactAdaptation(.popover)
    }
}
