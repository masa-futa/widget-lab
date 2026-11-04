import SwiftUI

nonisolated extension CatalogEntry {
    static let confirmationDialog = CatalogEntry(
        id: "confirmationDialog",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、選べる操作を並べた確かめのダイアログを出す modifier。iPhone では下から出る。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/confirmationdialog(_:ispresented:titlevisibility:actions:message:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "confirmationDialog", id: "confirmationDialog.title", .fixed(code: "\"写真を変える\""), required: true,
                summary: "題名"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.isPresented", label: "isPresented",
                .fixed(code: "$shows"), required: true, summary: "出すかどうかの Binding"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.titleVisibility", label: "titleVisibility",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 1), on: true,
                summary: "題名を出すか。.automatic は iPhone では隠す"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.actions", label: "actions",
                .fixed(code: "{ Button(\"写真を撮る\") { }; Button(\"削除\", role: .destructive) { } }"),
                required: true, summary: "並べる操作。やめるボタンは自動で足される"),
            .modifier(
                "confirmationDialog", id: "confirmationDialog.message", label: "message",
                .fixed(code: "{ Text(\"プロフィールの写真\") }"), on: true, summary: "題名の下の説明"),
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"写真を変える\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(
                ConfirmationDialogDemo(
                    visibility: v.pick(
                        "confirmationDialog.titleVisibility", from: [Visibility.automatic, .visible, .hidden]),
                    showsMessage: v["confirmationDialog.message"] != nil))
        }
    )
}

private struct ConfirmationDialogDemo: View {
    let visibility: Visibility?
    let showsMessage: Bool
    @State private var shows = false
    @State private var last = "（まだ押していない）"

    var body: some View {
        VStack(spacing: 12) {
            Button("写真を変える") { shows = true }
                .buttonStyle(.borderedProminent)
                // required でない引数（titleVisibility・message）がどれも OFF なら、modifier ごと付けない
                .apply(visibility != nil || showsMessage ? () : nil) { view, _ in
                    view.confirmationDialog("写真を変える", isPresented: $shows, titleVisibility: visibility ?? .automatic) {
                        Button("写真を撮る") { last = "写真を撮る" }
                        Button("削除", role: .destructive) { last = "削除" }
                    } message: {
                        if showsMessage {
                            Text("プロフィールの写真")
                        }
                    }
                }
            Text("押したボタン: \(last)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
