import SwiftUI

nonisolated extension CatalogEntry {
    static let strikethrough = CatalogEntry(
        id: "strikethrough",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字に取り消し線を引く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/strikethrough(_:pattern:color:)")!,
        stage: .card,
        properties: [
            .modifier(
                "strikethrough", .toggle(initial: true), on: true, summary: "取り消し線を引くか（OFF なら既定の true）"),
            .modifier(
                "strikethrough", id: "strikethrough.pattern", label: "pattern",
                .choice(
                    [Choice(".solid"), Choice(".dot"), Choice(".dash"), Choice(".dashDot"), Choice(".dashDotDot")],
                    initial: 0),
                summary: "線の模様"),
            .modifier(
                "strikethrough", id: "strikethrough.color", label: "color", .color(initial: 0), on: true,
                summary: "線の色（OFF なら文字と同じ色）"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Strikethrough 取り消し\""], suffix: [".font(.title)"]),
        build: { v in
            let isOn =
                v["strikethrough"] != nil || v["strikethrough.pattern"] != nil || v["strikethrough.color"] != nil
            return AnyView(
                Text("Strikethrough 取り消し")
                    .apply(isOn ? () : nil) { view, _ in
                        view.strikethrough(
                            v.flag("strikethrough") ?? true,
                            pattern: v.pick(
                                "strikethrough.pattern",
                                from: [Text.LineStyle.Pattern.solid, .dot, .dash, .dashDot, .dashDotDot]) ?? .solid,
                            color: v.color("strikethrough.color"))
                    }
                    .font(.title)
            )
        }
    )
}
