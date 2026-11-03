import SwiftUI

nonisolated extension CatalogEntry {
    static let allowsTightening = CatalogEntry(
        id: "allowsTightening",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字が 1 行に収まらないとき、省く前に字の間を詰めて収めてよいかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/allowstightening(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "allowsTightening", .toggle(initial: true), on: true,
                summary: "字の間を詰めてよいか（false なら付けないのと同じで、すぐ「…」で省く）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"Tightening squeezes letters\""],
            suffix: [".lineLimit(1)", ".frame(width: 206)"]),
        build: { v in
            AnyView(
                Text("Tightening squeezes letters")
                    .apply(v.flag("allowsTightening")) { $0.allowsTightening($1) }
                    .lineLimit(1)
                    .frame(width: 206)
                    .border(.secondary)
            )
        }
    )
}
