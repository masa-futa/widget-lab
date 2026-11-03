import SwiftUI

nonisolated extension CatalogEntry {
    static let tracking = CatalogEntry(
        id: "tracking",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字ごとの後ろに、決まった間隔を足す modifier。kerning と違い、合字（fi など）は外れることがある。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tracking(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "tracking", .slider(range: -4...12, step: 1, initial: 8), on: true,
                summary: "足す間隔（ポイント。マイナスで詰める）")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"Tracking 字間\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("Tracking 字間")
                    .apply(v.number("tracking")) { $0.tracking($1) }
                    .font(.title)
            )
        }
    )
}
