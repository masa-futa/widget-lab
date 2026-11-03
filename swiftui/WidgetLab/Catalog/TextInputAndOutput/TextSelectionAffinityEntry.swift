import SwiftUI

nonisolated extension CatalogEntry {
    static let textSelectionAffinity = CatalogEntry(
        id: "textSelectionAffinity",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "折り返しの境目にカーソルを置いたとき、前の行の末尾と次の行の頭のどちらに出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textselectionaffinity(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textSelectionAffinity",
                .choice([Choice(".automatic"), Choice(".upstream"), Choice(".downstream")], initial: 1), on: true,
                summary: "境目のカーソルを前の行の末尾（.upstream）か次の行の頭（.downstream）に寄せる")
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            AnyView(
                TextInputDemo("折り返しの境目をタップして、カーソルがどちらの行に出るかを見る。長い文字は枠の幅で折り返す。") {
                    text in
                    TextEditor(text: text)
                        .apply(
                            v.pick(
                                "textSelectionAffinity",
                                from: [TextSelectionAffinity.automatic, .upstream, .downstream])
                        ) { $0.textSelectionAffinity($1) }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
