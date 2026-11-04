import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollContentBackground = CatalogEntry(
        id: "scrollContentBackground",
        kind: .modifier,
        topic: .scrollViews,
        summary: "List・Form・TextEditor などのスクロールする View の、決まった地の色を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollcontentbackground(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollContentBackground",
                .choice([Choice(".hidden"), Choice(".visible"), Choice(".automatic")], initial: 0),
                on: true, summary: "決まった地を出すか（隠すと、後ろの .background が見える）")
        ],
        code: CodeTemplate(
            call: "List", trailing: " {\n    Text(\"りんご\")\n    Text(\"みかん\")\n}", suffix: [".background(.mint)"]),
        build: { v in
            AnyView(
                List {
                    Text("りんご")
                    Text("みかん")
                }
                .apply(v.pick("scrollContentBackground", from: [Visibility.hidden, .visible, .automatic])) {
                    $0.scrollContentBackground($1)
                }
                .background(.mint)
            )
        }
    )
}
