import SwiftUI

nonisolated extension CatalogEntry {
    static let fixedSize = CatalogEntry(
        id: "fixedSize",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View を、置き場所の大きさにかかわらず、自分のちょうどよい大きさにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/fixedsize()")!,
        stage: .card,
        properties: [
            .modifier(
                "fixedSize",
                .choice(
                    [
                        Choice("両方", code: ""), Choice("横だけ", code: "horizontal: true, vertical: false"),
                        Choice("縦だけ", code: "horizontal: false, vertical: true"),
                    ],
                    initial: 2),
                on: true, summary: "ちょうどよい大きさにする向き")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"長い文字は、置き場所の幅で折り返す\""],
            suffix: [".background(.yellow)", ".frame(width: 120, height: 40)", ".border(.secondary)"]),
        build: { v in
            AnyView(
                Text("長い文字は、置き場所の幅で折り返す")
                    .apply(v.pick("fixedSize", from: [(true, true), (true, false), (false, true)])) {
                        $0.fixedSize(horizontal: $1.0, vertical: $1.1)
                    }
                    .background(.yellow)
                    .frame(width: 120, height: 40)
                    .border(.secondary)
            )
        }
    )
}
