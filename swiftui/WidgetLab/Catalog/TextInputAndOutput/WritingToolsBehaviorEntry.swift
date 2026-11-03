import SwiftUI

nonisolated extension CatalogEntry {
    static let writingToolsBehavior = CatalogEntry(
        id: "writingToolsBehavior",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "Apple Intelligence の作文ツール（書き直し・要約など）を、文字の上でどこまで使えるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/writingtoolsbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "writingToolsBehavior",
                .choice(
                    [Choice(".automatic"), Choice(".complete"), Choice(".limited"), Choice(".disabled")], initial: 3),
                on: true,
                summary:
                    "使える範囲（.complete はその場で書き換える、.limited は別の枠に出す、.disabled は使わせない）。Apple Intelligence が使える端末で、文字を選ぶと試せる"
            )
        ],
        code: CodeTemplate(call: "TextEditor", fixedArguments: ["text: $memo"], suffix: [".frame(height: 120)"]),
        build: { v in
            AnyView(
                TextInputDemo("明日の会議は 10 時から。資料はまだできていないので、朝のうちに仕上げる。") { text in
                    TextEditor(text: text)
                        .apply(
                            v.pick(
                                "writingToolsBehavior",
                                from: [WritingToolsBehavior.automatic, .complete, .limited, .disabled])
                        ) { $0.writingToolsBehavior($1) }
                        .frame(height: 120)
                }
                .padding()
            )
        }
    )
}
