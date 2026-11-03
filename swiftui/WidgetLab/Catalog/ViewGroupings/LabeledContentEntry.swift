import SwiftUI

nonisolated extension CatalogEntry {
    static let labeledContent = CatalogEntry(
        id: "LabeledContent",
        kind: .view,
        topic: .viewGroupings,
        summary: "名前と値を 1 組にして並べる View。Form の中では、名前を左、値を右に置く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/labeledcontent")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "バージョン"), required: true, summary: "名前"),
            .argument("value", .text(initial: "1.0"), required: true, summary: "値"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠す（読み上げには残る）"),
        ],
        code: CodeTemplate(prefix: ["Form {"], call: "LabeledContent", closing: ["}"]),
        build: { v in
            AnyView(
                Form {
                    LabeledContent(v.text("title") ?? "", value: v.text("value") ?? "")
                        .apply(v.flag("labelsHidden")) { view, _ in view.labelsHidden() }
                }
            )
        }
    )
}
