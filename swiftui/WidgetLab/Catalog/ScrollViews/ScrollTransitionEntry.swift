import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollTransition = CatalogEntry(
        id: "scrollTransition",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView の見える範囲に出入りする子に、その途中の段階に合わせた効果をかける modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/scrolltransition(_:axis:transition:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollTransition", id: "scrollTransition.configuration",
                .choice([Choice(".interactive"), Choice(".animated")], initial: 0), required: true,
                summary: "効果の動き（.interactive は指に合わせ、.animated はアニメーションで切り替える）"),
            .modifier(
                "scrollTransition", id: "scrollTransition.transition", label: "transition",
                .choice(
                    [
                        Choice(
                            "薄く・小さく",
                            code:
                                "{ content, phase in content.opacity(phase.isIdentity ? 1 : 0.2).scaleEffect(phase.isIdentity ? 1 : 0.7) }"
                        ),
                        Choice("横にずらす", code: "{ content, phase in content.offset(x: phase.value * 120) }"),
                        Choice("回す", code: "{ content, phase in content.rotationEffect(.degrees(phase.value * 30)) }"),
                    ],
                    initial: 0),
                on: true, summary: "出入りの途中でかける効果"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    VStack {", "        ForEach(1...20, id: \\.self) { i in",
                "            Text(\"行 \\(i)\")",
                "                .frame(maxWidth: .infinity, minHeight: 44)",
            ],
            indent: 16, call: ".background", fixedArguments: [".yellow"], closing: ["        }", "    }", "}"]),
        build: { v in
            let configuration =
                v.pick("scrollTransition.configuration", from: [ScrollTransitionConfiguration.interactive, .animated])
                ?? .interactive
            let transition = v.pick("scrollTransition.transition", from: [0, 1, 2])
            return AnyView(
                ScrollView {
                    VStack {
                        ForEach(1...20, id: \.self) { i in
                            Text("行 \(i)")
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .background(.yellow)
                                .apply(transition) { view, kind in
                                    switch kind {
                                    case 0:
                                        view.scrollTransition(configuration) { content, phase in
                                            content.opacity(phase.isIdentity ? 1 : 0.2).scaleEffect(
                                                phase.isIdentity ? 1 : 0.7)
                                        }
                                    case 1:
                                        view.scrollTransition(configuration) { content, phase in
                                            content.offset(x: phase.value * 120)
                                        }
                                    default:
                                        view.scrollTransition(configuration) { content, phase in
                                            content.rotationEffect(.degrees(phase.value * 30))
                                        }
                                    }
                                }
                        }
                    }
                }
            )
        }
    )
}
