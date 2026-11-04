import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollBounceBehavior = CatalogEntry(
        id: "scrollBounceBehavior",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView が端に着いたときに跳ね返るかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollbouncebehavior(_:axes:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollBounceBehavior",
                .choice([Choice(".basedOnSize"), Choice(".always"), Choice(".automatic")], initial: 0), on: true,
                summary: "跳ね返り方（.basedOnSize は、中身が枠より小さいと跳ね返らない）")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    Text(\"行 1\")\n    Text(\"行 2\")\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    Text("行 1")
                    Text("行 2")
                }
                .frame(maxWidth: .infinity)
                .apply(v.pick("scrollBounceBehavior", from: [ScrollBounceBehavior.basedOnSize, .always, .automatic])) {
                    $0.scrollBounceBehavior($1)
                }
            )
        }
    )
}
