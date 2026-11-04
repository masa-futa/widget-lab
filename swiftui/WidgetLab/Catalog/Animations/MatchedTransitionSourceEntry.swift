import SwiftUI

nonisolated extension CatalogEntry {
    static let matchedTransitionSource = CatalogEntry(
        id: "matchedTransitionSource",
        kind: .modifier,
        topic: .animations,
        summary: "この View を、ズームの遷移（navigationTransition(.zoom)）の始まりの場所にする modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/matchedtransitionsource(id:in:configuration:)")!,
        stage: .card,
        properties: [
            .modifier(
                "matchedTransitionSource", id: "matchedTransitionSource.id", label: "id", .fixed(code: "\"photo\""),
                required: true, summary: "遷移の相手と合わせる id"),
            .modifier(
                "matchedTransitionSource", id: "matchedTransitionSource.in", label: "in", .fixed(code: "namespace"),
                required: true, summary: "id を探す名前空間（@Namespace）"),
            .modifier(
                "matchedTransitionSource", id: "matchedTransitionSource.configuration", label: "configuration",
                .choice(
                    [
                        Choice("そのまま", code: "{ $0 }"),
                        Choice("背景と角", code: "{ $0.background(.yellow).clipShape(.rect(cornerRadius: 16)) }"),
                        Choice("影", code: "{ $0.shadow(radius: 8) }"),
                    ],
                    initial: 1),
                on: true,
                summary: "遷移のあいだの、始まりの View の見た目。OFF にすると modifier ごと外れ、画面の真ん中から開く"),
        ],
        code: CodeTemplate(
            call: "Button",
            trailing:
                " { isShown = true } label: {\n    Image(systemName: \"photo.fill\")\n        .font(.largeTitle)\n"
                + "        .frame(width: 80, height: 80)\n        .background(.yellow, in: .rect(cornerRadius: 16))\n}",
            suffix: [".sheet(isPresented: $isShown) {"],
            closing: [
                "    Image(systemName: \"photo.fill\")", "        .font(.system(size: 120))",
                "        .navigationTransition(.zoom(sourceID: \"photo\", in: namespace))", "}",
            ]),
        build: { v in
            AnyView(
                ZoomTransitionDemo(
                    source: v.pick(
                        "matchedTransitionSource.configuration",
                        from: [ZoomTransitionDemo.Source.plain, .rounded, .shadow]),
                    zooms: true))
        }
    )
}
