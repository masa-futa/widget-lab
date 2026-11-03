import SwiftUI

nonisolated extension CatalogEntry {
    static let baselineOffset = CatalogEntry(
        id: "baselineOffset",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を、文字の並ぶ線（ベースライン）から上下にずらす modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/baselineoffset(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "baselineOffset", .slider(range: -20...20, step: 2, initial: 12), on: true,
                summary: "ずらす量（ポイント。プラスで上、マイナスで下）")
        ],
        code: CodeTemplate(
            prefix: ["HStack(alignment: .firstTextBaseline, spacing: 0) {", "    Text(\"E = mc\")"], call: "Text",
            fixedArguments: ["\"2\""], suffix: [".font(.title3)"], closing: ["}", ".font(.largeTitle)"]),
        build: { v in
            AnyView(
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text("E = mc")
                    Text("2")
                        .apply(v.number("baselineOffset")) { $0.baselineOffset($1) }
                        .font(.title3)
                }
                .font(.largeTitle)
            )
        }
    )
}
