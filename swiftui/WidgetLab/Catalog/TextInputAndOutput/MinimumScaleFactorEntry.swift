import SwiftUI

nonisolated extension CatalogEntry {
    static let minimumScaleFactor = CatalogEntry(
        id: "minimumScaleFactor",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字が収まらないとき、どこまで小さくして収めてよいかを、元の大きさとの比で決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/minimumscalefactor(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "minimumScaleFactor", .slider(range: 0.1...1, step: 0.1, initial: 0.5), on: true,
                summary: "小さくしてよい下限（1 なら小さくしない）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"長い文字は、枠に収まるまで小さくなる\""],
            suffix: [".lineLimit(1)", ".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("長い文字は、枠に収まるまで小さくなる")
                    .apply(v.number("minimumScaleFactor")) { $0.minimumScaleFactor($1) }
                    .lineLimit(1)
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
