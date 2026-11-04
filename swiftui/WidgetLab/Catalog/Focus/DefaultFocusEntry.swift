import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultFocus = CatalogEntry(
        id: "defaultFocus",
        kind: .modifier,
        topic: .focus,
        summary: "この View の中で、はじめにフォーカスを置く先を決める modifier。@FocusState にその値を入れる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaultfocus(_:_:priority:)")!,
        noteReason: "iPhone では、はじめのフォーカスが決まらなかった（入力欄は選ばれず、キーボードも出ない）。iPad・Mac のキーボード操作や Apple TV で、はじめにフォーカスを置く先が決まる",
        properties: [
            .modifier(
                "defaultFocus", id: "defaultFocus.binding", label: nil, .fixed(code: "$field"), required: true,
                summary: "フォーカスを持つ @FocusState"),
            .modifier(
                "defaultFocus", id: "defaultFocus.value", label: nil,
                .choice([Choice(".mail"), Choice(".name")], initial: 0), on: true, summary: "はじめにフォーカスを置く欄"),
            .modifier(
                "defaultFocus", id: "defaultFocus.priority", label: "priority",
                .choice([Choice(".automatic"), Choice(".userInitiated")], initial: 0), required: true,
                summary: "いつ効かせるか。.userInitiated は、使う人の操作でフォーカスを決めるときにも効く"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    TextField(\"名前\", text: $name).focused($field, equals: .name)\n    TextField(\"メール\", text: $mail).focused($field, equals: .mail)\n}"
        )
    )
}
