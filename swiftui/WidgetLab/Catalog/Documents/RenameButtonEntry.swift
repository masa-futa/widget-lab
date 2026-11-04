import SwiftUI

nonisolated extension CatalogEntry {
    static let renameButton = CatalogEntry(
        id: "RenameButton",
        kind: .view,
        topic: .documents,
        summary: "名前を変える操作を始める、決まった見た目のボタン。押すと、まわりの renameAction で決めた動きが起きる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/renamebutton")!,
        stage: .card,
        properties: [
            .modifier(
                "renameAction", .fixed(code: "$isFocused"), on: true,
                summary: "押したときの動き。FocusState を渡すと、名前の欄に入力の印が入る。付けないと押せない"),
            .modifier(
                "labelStyle",
                .choice([Choice(".titleAndIcon"), Choice(".iconOnly"), Choice(".titleOnly")], initial: 0),
                summary: "ボタンの文と絵の出し方"),
            .modifier(
                "buttonStyle", .choice([Choice(".bordered"), Choice(".borderedProminent")], initial: 0), on: true,
                summary: "ボタンの見た目"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    TextField(\"名前\", text: $name)\n        .focused($isFocused)\n    RenameButton()\n}"),
        build: { v in
            AnyView(
                RenameDemo(
                    renames: v["renameAction"] != nil,
                    labelStyle: v.pick("labelStyle", from: [0, 1, 2]),
                    prominent: v.pick("buttonStyle", from: [false, true])))
        }
    )
}

private struct RenameDemo: View {
    let renames: Bool
    let labelStyle: Int?
    let prominent: Bool?
    @State private var name = "買い物メモ"
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 12) {
            TextField("名前", text: $name)
                .focused($isFocused)
                .textFieldStyle(.bordered)
            RenameButton()
        }
        .apply(renames ? () : nil) { view, _ in view.renameAction($isFocused) }
        .apply(labelStyle) { view, style in
            switch style {
            case 1: view.labelStyle(.iconOnly)
            case 2: view.labelStyle(.titleOnly)
            default: view.labelStyle(.titleAndIcon)
            }
        }
        .apply(prominent) { view, prominent in
            if prominent {
                view.buttonStyle(.borderedProminent)
            } else {
                view.buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
