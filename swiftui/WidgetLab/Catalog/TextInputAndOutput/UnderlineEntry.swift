import SwiftUI

nonisolated extension CatalogEntry {
    static let underline = CatalogEntry(
        id: "underline",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字に下線を引く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/underline(_:pattern:color:)")!,
        stage: .card,
        properties: [
            .modifier("underline", .toggle(initial: true), on: true, summary: "下線を引くか（OFF なら既定の true）"),
            .modifier(
                "underline", id: "underline.pattern", label: "pattern",
                .choice(
                    [Choice(".solid"), Choice(".dot"), Choice(".dash"), Choice(".dashDot"), Choice(".dashDotDot")],
                    initial: 2),
                on: true, summary: "線の模様"),
            .modifier(
                "underline", id: "underline.color", label: "color", .color(initial: 0),
                summary: "線の色（OFF なら文字と同じ色）"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Underline 下線\""], suffix: [".font(.title)"]),
        build: { v in
            let isOn = v["underline"] != nil || v["underline.pattern"] != nil || v["underline.color"] != nil
            return AnyView(
                Text("Underline 下線")
                    .apply(isOn ? () : nil) { view, _ in
                        view.underline(
                            v.flag("underline") ?? true,
                            pattern: v.pick(
                                "underline.pattern",
                                from: [Text.LineStyle.Pattern.solid, .dot, .dash, .dashDot, .dashDotDot])
                                ?? .solid,
                            color: v.color("underline.color"))
                    }
                    .font(.title)
            )
        }
    )
}
