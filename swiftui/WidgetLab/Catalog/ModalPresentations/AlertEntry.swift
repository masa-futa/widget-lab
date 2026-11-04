import SwiftUI

nonisolated extension CatalogEntry {
    static let alert = CatalogEntry(
        id: "alert",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、題名とボタンを持つアラートを出す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:message:)")!,
        stage: .card,
        properties: [
            .modifier(
                "alert",
                .choice(
                    [
                        Choice(
                            "OK だけ",
                            code: "\"保存しました\", isPresented: $shows, actions: { Button(\"OK\") { } }"),
                        Choice(
                            "削除と取り消し",
                            code:
                                "\"削除しますか？\", isPresented: $shows, actions: { Button(\"削除\", role: .destructive) { }; Button(\"やめる\", role: .cancel) { } }, message: { Text(\"元に戻せません\") }"
                        ),
                    ], initial: 1), on: true,
                summary: "題名・出すかどうかの Binding・ボタン（actions）・説明（message）")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"アラートを出す\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(AlertDemo(kind: v.pick("alert", from: [AlertDemo.Kind.ok, .delete])))
        }
    )
}

private struct AlertDemo: View {
    enum Kind {
        case ok, delete
    }

    let kind: Kind?
    @State private var shows = false
    @State private var last = "（まだ押していない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("アラートを出す") { shows = true }
                .buttonStyle(.borderedProminent)
                .apply(kind) { view, kind in
                    switch kind {
                    case .ok:
                        view.alert("保存しました", isPresented: $shows) {
                            Button("OK") { last = "OK" }
                        }
                    case .delete:
                        view.alert("削除しますか？", isPresented: $shows) {
                            Button("削除", role: .destructive) { last = "削除" }
                            Button("やめる", role: .cancel) { last = "やめる" }
                        } message: {
                            Text("元に戻せません")
                        }
                    }
                }
            Text("押したボタン: \(last)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
