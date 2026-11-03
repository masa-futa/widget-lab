import SwiftUI

nonisolated extension CatalogEntry {
    static let lineLimit = CatalogEntry(
        id: "lineLimit",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "文字を出す行の数の上限を決める modifier。あふれた分は「…」で省く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/linelimit(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "lineLimit",
                .choice(
                    [Choice("1"), Choice("2"), Choice("3"), Choice("2 行を取っておく", code: "2, reservesSpace: true")],
                    initial: 1),
                on: true, summary: "行の数の上限（OFF なら上限なし。reservesSpace は短い文字でもその行の数の高さを取る）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"行の数の上限を決めると、あふれた分は省かれる。上限がなければ、文字の分だけ行が増える。\""],
            suffix: [".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("行の数の上限を決めると、あふれた分は省かれる。上限がなければ、文字の分だけ行が増える。")
                    .apply(v.pick("lineLimit", from: [(1, false), (2, false), (3, false), (2, true)])) {
                        $0.lineLimit($1.0, reservesSpace: $1.1)
                    }
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
