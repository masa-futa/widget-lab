import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyHStack = CatalogEntry(
        id: "LazyHStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を横に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyhstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 0), on: true,
                summary: "子の縦の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
            .argument(
                "pinnedViews",
                .choice([Choice("[.sectionHeaders]"), Choice("[.sectionHeaders, .sectionFooters]")], initial: 0),
                summary: "スクロールしても端に残す、節の見出しと結び"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView(.horizontal) {"], call: "LazyHStack",
            trailing: " {\n        Section {\n            ForEach(1...20, id: \\.self) { i in\n"
                + "                Text(\"\\(i)\")\n                    .frame(width: 44, height: i % 2 == 0 ? 40 : 80)\n"
                + "                    .background(.yellow)\n            }\n        } header: {\n            Text(\"見出し\")\n"
                + "        } footer: {\n            Text(\"結び\")\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    LazyHStack(
                        alignment: v.pick("alignment", from: [VerticalAlignment.top, .center, .bottom]) ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) },
                        pinnedViews: v.pick(
                            "pinnedViews", from: [[.sectionHeaders], [.sectionHeaders, .sectionFooters]])
                            ?? PinnedScrollableViews()
                    ) {
                        Section {
                            ForEach(1...20, id: \.self) { i in
                                Text("\(i)")
                                    .frame(width: 44, height: i % 2 == 0 ? 40 : 80)
                                    .background(.yellow)
                            }
                        } header: {
                            Text("見出し").background(.background)
                        } footer: {
                            Text("結び").background(.background)
                        }
                    }
                }
            )
        }
    )
}
