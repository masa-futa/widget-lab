import SwiftUI

nonisolated extension CatalogEntry {
    static let transition = CatalogEntry(
        id: "transition",
        kind: .modifier,
        topic: .animations,
        summary: "View が現れるときと消えるときの動き方を決める modifier。アニメーションの中で出し入れしたときに効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transition(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transition",
                .choice(
                    [
                        Choice(".opacity"), Choice(".slide"), Choice(".scale"), Choice(".move(edge: .bottom)"),
                        Choice(".push(from: .leading)"), Choice(".blurReplace"),
                    ],
                    initial: 1),
                on: true, summary: "出し入れの動き方（OFF なら .opacity）")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {",
                "    Button(\"出し入れ\") { withAnimation { isShown.toggle() } }",
                "    if isShown {",
                "        Text(\"見本\")",
                "            .padding()",
            ],
            indent: 12, call: ".background", fixedArguments: [".yellow"], closing: ["    }", "}"]),
        build: { v in
            AnyView(TransitionDemo(transition: v.pick("transition", from: TransitionDemo.transitions)))
        }
    )
}

private struct TransitionDemo: View {
    @MainActor static let transitions: [AnyTransition] = [
        .opacity, .slide, .scale, .move(edge: .bottom), .push(from: .leading), AnyTransition(.blurReplace),
    ]

    /// nil なら modifier をかけない
    let transition: AnyTransition?
    @State private var isShown = true

    var body: some View {
        VStack {
            Button("出し入れ") { withAnimation { isShown.toggle() } }
                .buttonStyle(.bordered)
            if isShown {
                Text("見本")
                    .padding()
                    .background(.yellow)
                    .apply(transition) { $0.transition($1) }
            }
        }
        .frame(width: 200, height: 120, alignment: .top)
    }
}
