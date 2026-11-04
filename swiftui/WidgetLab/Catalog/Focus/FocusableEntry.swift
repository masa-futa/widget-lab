import SwiftUI

nonisolated extension CatalogEntry {
    static let focusable = CatalogEntry(
        id: "focusable",
        kind: .modifier,
        topic: .focus,
        summary: "入力欄でない View を、フォーカスを受けられるようにする modifier。受けられると、@FocusState でフォーカスを当てられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusable(_:interactions:)")!,
        stage: .card,
        properties: [
            .modifier(
                "focusable", id: "focusable.isFocusable", label: nil, .toggle(initial: true), on: true,
                summary: "フォーカスを受けられるか。外すか false にすると、ボタンを押してもフォーカスが来ない"),
            .modifier(
                "focusable", id: "focusable.interactions", label: "interactions",
                .choice([Choice(".activate"), Choice(".edit"), Choice(".automatic")], initial: 0),
                summary: "フォーカスで受ける操作の種類（キーボードやリモコンで使う）"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"札にフォーカス\") { isFocused = true }"], call: "Text",
            fixedArguments: ["\"札\""], suffix: [".focused($isFocused)"], closing: ["}"]),
        build: { v in
            AnyView(
                FocusableDemo(
                    isFocusable: v["focusable.isFocusable"] == nil ? nil : v.flag("focusable.isFocusable") ?? true,
                    interactions: v.pick(
                        "focusable.interactions", from: [FocusInteractions.activate, .edit, .automatic])))
        }
    )
}

private struct FocusableDemo: View {
    /// nil なら focusable をかけない（interactions だけ ON なら、既定の true でかける）
    let isFocusable: Bool?
    let interactions: FocusInteractions?
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 8) {
            Button("札にフォーカス") { isFocused = true }
                .buttonStyle(.bordered)
            tag
                .focused($isFocused)
            Text("isFocused: \(isFocused)")
                .monospaced()
        }
    }

    @ViewBuilder
    private var tag: some View {
        let text = Text("札")
            .padding(8)
            .background(isFocused ? Color.yellow : Color.gray.opacity(0.3), in: .rect(cornerRadius: 6))
        switch (isFocusable, interactions) {
        case (let flag?, let interactions?): text.focusable(flag, interactions: interactions)
        case (let flag?, nil): text.focusable(flag)
        case (nil, let interactions?): text.focusable(interactions: interactions)
        case (nil, nil): text
        }
    }
}
