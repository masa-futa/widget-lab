import SwiftUI

nonisolated extension CatalogEntry {
    static let lineSpacing = CatalogEntry(
        id: "lineSpacing",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "複数行の文字の、行と行の間を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/linespacing(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "lineSpacing", .slider(range: 0...24, step: 2, initial: 12), on: true,
                summary: "行と行の間に足す量（ポイント）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"行と行の間を広げると、長い文字が読みやすくなることがある。\""],
            suffix: [".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("行と行の間を広げると、長い文字が読みやすくなることがある。")
                    .apply(v.number("lineSpacing")) { $0.lineSpacing($1) }
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
