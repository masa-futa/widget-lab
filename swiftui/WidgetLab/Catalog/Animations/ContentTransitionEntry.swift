import SwiftUI

nonisolated extension CatalogEntry {
    static let contentTransition = CatalogEntry(
        id: "contentTransition",
        kind: .modifier,
        topic: .animations,
        summary: "View の中身（文字や記号）が変わるときの動き方を決める modifier。アニメーションの中で変えたときに効く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/contenttransition(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "contentTransition",
                .choice(
                    [
                        Choice(".numericText()"), Choice(".numericText(countsDown: true)"), Choice(".interpolate"),
                        Choice(".opacity"), Choice(".identity"),
                    ],
                    initial: 0),
                on: true, summary: "中身の変わり方。.numericText は数字を桁ごとに送る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"\\(count)\")"], indent: 8, call: ".font",
            fixedArguments: [".system(size: 56, weight: .bold)"],
            closing: ["    Button(\"+1\") { withAnimation { count += 1 } }", "}"]),
        build: { v in
            AnyView(
                ContentTransitionDemo(
                    transition: v.pick(
                        "contentTransition",
                        from: [
                            ContentTransition.numericText(), .numericText(countsDown: true), .interpolate, .opacity,
                            .identity,
                        ])))
        }
    )
}

private struct ContentTransitionDemo: View {
    /// nil なら modifier をかけない
    let transition: ContentTransition?
    @State private var count = 9

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.system(size: 56, weight: .bold))
                .apply(transition) { $0.contentTransition($1) }
            Button("+1") { withAnimation { count += 1 } }
                .buttonStyle(.bordered)
        }
    }
}
