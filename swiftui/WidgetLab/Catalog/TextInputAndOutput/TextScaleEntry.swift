import SwiftUI

nonisolated extension CatalogEntry {
    static let textScale = CatalogEntry(
        id: "textScale",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を、まわりの文字より一段小さい大きさ（.secondary）で出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textscale(_:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textScale", .choice([Choice(".secondary"), Choice(".default")], initial: 0), on: true,
                summary: "文字の大きさの段（.secondary は一段小さい）")
        ],
        code: CodeTemplate(
            prefix: ["HStack(alignment: .firstTextBaseline) {", "    Text(\"1,280\")"], call: "Text",
            fixedArguments: ["\"円（税込）\""], closing: ["}", ".font(.title)"]),
        build: { v in
            AnyView(
                HStack(alignment: .firstTextBaseline) {
                    Text("1,280")
                    Text("円（税込）")
                        .apply(v.pick("textScale", from: [Text.Scale.secondary, .default])) { $0.textScale($1) }
                }
                .font(.title)
            )
        }
    )
}
