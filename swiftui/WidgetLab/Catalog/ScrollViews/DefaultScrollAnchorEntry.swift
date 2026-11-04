import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultScrollAnchor = CatalogEntry(
        id: "defaultScrollAnchor",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView が最初にどこを見せるか（中身のどの点を合わせるか）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaultscrollanchor(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "defaultScrollAnchor", .choice([Choice(".bottom"), Choice(".center"), Choice(".top")], initial: 0),
                on: true, summary: "最初に見せるところ（.bottom はチャットのように末尾から）")
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
                .apply(v.pick("defaultScrollAnchor", from: [UnitPoint.bottom, .center, .top])) {
                    $0.defaultScrollAnchor($1)
                }
            )
        }
    )
}
