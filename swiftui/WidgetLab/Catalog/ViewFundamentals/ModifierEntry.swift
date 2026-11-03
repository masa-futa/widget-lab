import SwiftUI

nonisolated extension CatalogEntry {
    static let modifier = CatalogEntry(
        id: "modifier",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "自分で作った ViewModifier を View にかける modifier。いくつもの modifier の組を、名前を付けて使い回せる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/modifier(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "modifier",
                .choice(
                    [Choice("Card()"), Choice("Card(color: .mint)"), Choice("EmptyModifier()")], initial: 0),
                on: true, summary: "かける ViewModifier。EmptyModifier は何もしない")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"見本\""],
            closing: [
                "",
                "struct Card: ViewModifier {",
                "    var color: Color = .yellow",
                "",
                "    func body(content: Content) -> some View {",
                "        content",
                "            .padding()",
                "            .background(color, in: .rect(cornerRadius: 12))",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                Text("見本")
                    .apply(v.pick("modifier", from: [Color?.some(.yellow), .some(.mint), .none])) { view, color in
                        if let color {
                            view.modifier(ModifierDemoCard(color: color))
                        } else {
                            view.modifier(EmptyModifier())
                        }
                    }
            )
        }
    )
}

private struct ModifierDemoCard: ViewModifier {
    var color: Color = .yellow

    func body(content: Content) -> some View {
        content
            .padding()
            .background(color, in: .rect(cornerRadius: 12))
    }
}
