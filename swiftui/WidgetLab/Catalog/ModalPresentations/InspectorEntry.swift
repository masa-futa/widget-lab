import SwiftUI

nonisolated extension CatalogEntry {
    static let inspector = CatalogEntry(
        id: "inspector",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true のとき、選んだものの詳しい設定を出す欄（インスペクタ）を出す modifier。iPhone ではシートで出る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/inspector(ispresented:content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "inspector",
                .fixed(code: "isPresented: $shows, content: { Text(\"詳しい設定\").presentationDetents([.medium]) }"),
                on: true, summary: "出すかどうかの Binding と中身。iPad や Mac では右に列として出る")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"インスペクタを出す\""], trailing: " { shows.toggle() }"),
        build: { v in
            AnyView(InspectorDemo(inspects: v["inspector"] != nil))
        }
    )
}

private struct InspectorDemo: View {
    let inspects: Bool
    @State private var shows = false

    var body: some View {
        Button("インスペクタを出す") { shows.toggle() }
            .buttonStyle(.borderedProminent)
            .apply(inspects ? () : nil) { view, _ in
                view.inspector(isPresented: $shows) {
                    ModalSheetContent("詳しい設定")
                        .presentationDetents([.medium])
                }
            }
    }
}
