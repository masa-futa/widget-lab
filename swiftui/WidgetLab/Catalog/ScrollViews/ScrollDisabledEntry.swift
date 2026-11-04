import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollDisabled = CatalogEntry(
        id: "scrollDisabled",
        kind: .modifier,
        topic: .scrollViews,
        summary: "中の ScrollView を、指でスクロールできないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrolldisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier("scrollDisabled", .toggle(initial: true), on: true, summary: "スクロールできなくする")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...30, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                    }
                }
                .apply(v.flag("scrollDisabled")) { $0.scrollDisabled($1) }
            )
        }
    )
}
