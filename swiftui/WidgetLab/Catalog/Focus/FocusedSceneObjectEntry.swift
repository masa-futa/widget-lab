import SwiftUI

nonisolated extension CatalogEntry {
    static let focusedSceneObject = CatalogEntry(
        id: "focusedSceneObject",
        kind: .modifier,
        topic: .focus,
        summary: "かけた View がシーン（窓）の中にあるあいだ、ObservableObject を出す modifier。フォーカスがどこにあっても（なくても）読める。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/focusedsceneobject(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "focusedSceneObject", .fixed(code: "notebook"), on: true,
                summary: "出す物（ObservableObject）。入力欄を選ばなくても、上の札に出る。シーンぜんたいに効くので、全画面で試す")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    NoteLabel()  // @FocusedObject var note: Note? を出す\n    TextField(\"題名\", text: $notebook.title)\n}"
        ),
        build: { v in
            AnyView(FocusedSceneObjectDemo(exposes: v["focusedSceneObject"] != nil))
        }
    )
}

private struct FocusedSceneObjectDemo: View {
    let exposes: Bool
    @StateObject private var notebook = DemoNote("メモ帳")

    var body: some View {
        VStack(spacing: 8) {
            FocusedNoteReader()
            NoteField(title: "題名", text: $notebook.title)
        }
        .padding()
        .frame(maxHeight: .infinity)
        .apply(exposes ? () : nil) { view, _ in view.focusedSceneObject(notebook) }
    }
}
