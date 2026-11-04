import SwiftUI

nonisolated extension CatalogEntry {
    static let animation = CatalogEntry(
        id: "animation",
        kind: .modifier,
        topic: .animations,
        summary: "value が変わったときに、この View の変化を指定のアニメーションで動かす modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/animation(_:value:)")!,
        stage: .card,
        properties: [
            .modifier(
                "animation",
                .choice(
                    [
                        Choice(".default"), Choice(".linear(duration: 1)"), Choice(".easeInOut(duration: 1)"),
                        Choice(".spring(duration: 1, bounce: 0.5)"), Choice(".bouncy"), Choice(".smooth"),
                    ],
                    initial: 3),
                on: true, summary: "動き方（OFF なら一瞬で変わる）"),
            .modifier(
                "animation", id: "animation.value", label: "value", .fixed(code: "moved"), required: true,
                summary: "見張る値。変わったときだけ動かす"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Circle()", "        .fill(.blue)", "        .frame(width: 40, height: 40)"],
            indent: 8, call: ".offset", fixedArguments: ["x: moved ? 80 : -80"],
            closing: ["    Button(\"動かす\") { moved.toggle() }", "}"]),
        build: { v in
            AnyView(
                AnimationDemo(
                    animation: v.pick(
                        "animation",
                        from: [
                            Animation.default, .linear(duration: 1), .easeInOut(duration: 1),
                            .spring(duration: 1, bounce: 0.5), .bouncy, .smooth,
                        ])))
        }
    )
}

private struct AnimationDemo: View {
    /// nil なら modifier をかけない
    let animation: Animation?
    @State private var moved = false

    var body: some View {
        VStack {
            Circle()
                .fill(.blue)
                .frame(width: 40, height: 40)
                .offset(x: moved ? 80 : -80)
                .apply(animation) { $0.animation($1, value: moved) }
            Button("動かす") { moved.toggle() }
                .buttonStyle(.bordered)
        }
        .frame(width: 220)
    }
}
