import SwiftUI

nonisolated extension CatalogEntry {
    static let selectionDisabled = CatalogEntry(
        id: "selectionDisabled",
        kind: .modifier,
        topic: .lists,
        summary: "List で、その行を選べないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/selectiondisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "selectionDisabled", .fixed(code: "item == \"みかん\""), on: true, summary: "選べなくする条件（みかんの行）")
        ],
        code: CodeTemplate(
            prefix: [
                "List(selection: $selected) {", "    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { item in",
            ],
            indent: 8, call: "Text", fixedArguments: ["item"], closing: ["    }", "}"]),
        build: { v in
            AnyView(SelectionDisabledDemo(disables: v["selectionDisabled"] != nil))
        }
    )
}

private struct SelectionDisabledDemo: View {
    let disables: Bool
    @State private var selected: String?

    var body: some View {
        List(selection: $selected) {
            ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { item in
                Text(item)
                    .apply(disables ? () : nil) { view, _ in
                        view.selectionDisabled(item == "みかん")
                    }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Text("選んだ行: \(selected ?? "なし")")
                .font(.caption)
                .padding(.bottom, 8)
        }
    }
}
