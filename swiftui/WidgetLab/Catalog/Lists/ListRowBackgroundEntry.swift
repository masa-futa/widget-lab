import SwiftUI

nonisolated extension CatalogEntry {
    static let listRowBackground = CatalogEntry(
        id: "listRowBackground",
        kind: .modifier,
        topic: .lists,
        summary: "List の行の後ろに、好きな View を背景として置く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/listrowbackground(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "listRowBackground",
                .choice(
                    [Choice("Color.yellow"), Choice("Color.mint.opacity(0.4)"), Choice("Capsule().fill(.orange)")],
                    initial: 0),
                on: true, summary: "背景に置く View")
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "Text", fixedArguments: ["\"りんご\""], closing: ["    Text(\"みかん\")", "}"]),
        build: { v in
            AnyView(
                List {
                    Text("りんご")
                        .apply(v.pick("listRowBackground", from: [0, 1, 2])) { view, i in
                            switch i {
                            case 0: view.listRowBackground(Color.yellow)
                            case 1: view.listRowBackground(Color.mint.opacity(0.4))
                            default: view.listRowBackground(Capsule().fill(.orange))
                            }
                        }
                    Text("みかん")
                }
            )
        }
    )
}
