import SwiftUI

nonisolated extension CatalogEntry {
    static let truncationMode = CatalogEntry(
        id: "truncationMode",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "収まらない文字を「…」で省くとき、頭・真ん中・末尾のどこを省くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/truncationmode(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "truncationMode", .choice([Choice(".head"), Choice(".middle"), Choice(".tail")], initial: 1), on: true,
                summary: "省く場所（OFF なら .tail）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"はじめ・なかほど・おわりのどこを省くか\""],
            suffix: [".lineLimit(1)", ".frame(width: 200)"]),
        build: { v in
            AnyView(
                Text("はじめ・なかほど・おわりのどこを省くか")
                    .apply(v.pick("truncationMode", from: [Text.TruncationMode.head, .middle, .tail])) {
                        $0.truncationMode($1)
                    }
                    .lineLimit(1)
                    .frame(width: 200)
                    .border(.secondary)
            )
        }
    )
}
