import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollView = CatalogEntry(
        id: "ScrollView",
        kind: .view,
        topic: .scrollViews,
        summary: "中身を、決めた向きにスクロールして見せる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scrollview")!,
        stage: .card,
        properties: [
            .argument(
                "axes", unlabeled: true,
                .choice([Choice(".vertical"), Choice(".horizontal"), Choice("[.horizontal, .vertical]")], initial: 2),
                on: true, summary: "スクロールする向き（OFF なら縦）"),
            .modifier("contentMargins", .slider(range: 0...40, step: 4, initial: 16), summary: "中身のまわりの余白"),
        ],
        code: CodeTemplate(
            call: "ScrollView",
            trailing: " {\n    VStack {\n        ForEach(1...12, id: \\.self) { row in\n            HStack {\n"
                + "                ForEach(1...8, id: \\.self) { column in\n"
                + "                    Text(\"\\(row)-\\(column)\")\n"
                + "                        .frame(width: 60, height: 40)\n"
                + "                        .background(.yellow)\n"
                + "                }\n            }\n        }\n    }\n}"),
        build: { v in
            let axes = v.pick("axes", from: [Axis.Set.vertical, .horizontal, [.horizontal, .vertical]]) ?? .vertical
            return AnyView(
                ScrollView(axes) {
                    VStack {
                        ForEach(1...12, id: \.self) { row in
                            HStack {
                                ForEach(1...8, id: \.self) { column in
                                    Text("\(row)-\(column)")
                                        .frame(width: 60, height: 40)
                                        .background(.yellow)
                                }
                            }
                        }
                    }
                }
                .apply(v.number("contentMargins")) { $0.contentMargins(CGFloat($1)) }
            )
        }
    )
}
