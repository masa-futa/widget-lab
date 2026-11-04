import SwiftUI

nonisolated extension CatalogEntry {
    static let keyboardShortcut = CatalogEntry(
        id: "keyboardShortcut",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ボタンやトグルに、ハードウェアのキーボードの近道（⌘S など）を割り当てる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/keyboardshortcut(_:modifiers:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "keyboardShortcut", .choice([Choice("\"s\""), Choice("\"d\""), Choice(".return")], initial: 0),
                on: true,
                summary: "割り当てるキー"),
            .modifier(
                "keyboardShortcut", id: "keyboardShortcut.modifiers", label: "modifiers",
                .choice([Choice(".command"), Choice(".option"), Choice("[.command, .shift]")], initial: 0),
                required: true, summary: "一緒に押す修飾キー。省くと .command"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存\""], trailing: " { print(\"保存\") }"),
        build: { v in
            AnyView(
                KeyboardShortcutDemo(
                    key: v.pick("keyboardShortcut", from: [KeyEquivalent("s"), "d", .return]),
                    modifiers: v.pick(
                        "keyboardShortcut.modifiers", from: [EventModifiers.command, .option, [.command, .shift]])
                        ?? .command))
        }
    )
}

private struct KeyboardShortcutDemo: View {
    /// nil なら keyboardShortcut を付けない
    let key: KeyEquivalent?
    let modifiers: EventModifiers
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        Button("保存") { recorder?.log("保存を押した") }
            .buttonStyle(.bordered)
            .apply(key) { $0.keyboardShortcut($1, modifiers: modifiers) }
    }
}
