import SwiftUI

nonisolated extension CatalogEntry {
    static let lazyVStack = CatalogEntry(
        id: "LazyVStack",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を縦に並べ、画面に入るときに初めて作る View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/lazyvstack")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                on: true, summary: "子の横の揃え方"),
            .argument("spacing", .slider(range: 0...40, step: 4, initial: 16), summary: "子と子の間の距離"),
            .argument(
                "pinnedViews",
                .choice([Choice("[.sectionHeaders]"), Choice("[.sectionHeaders, .sectionFooters]")], initial: 0),
                summary: "スクロールしても端に残す、節の見出しと結び"),
        ],
        code: CodeTemplate(
            prefix: ["ScrollView {"], call: "LazyVStack",
            trailing: " {\n        Section {\n            ForEach(1...20, id: \\.self) { i in\n"
                + "                Text(\"行 \\(i)\")\n                    .frame(width: i % 2 == 0 ? 80 : 160)\n"
                + "                    .background(.yellow)\n            }\n        } header: {\n            Text(\"見出し\")\n"
                + "        } footer: {\n            Text(\"結び\")\n        }\n    }",
            closing: ["}"]),
        build: { v in
            AnyView(
                ScrollView {
                    LazyVStack(
                        alignment: v.pick("alignment", from: [HorizontalAlignment.leading, .center, .trailing])
                            ?? .center,
                        spacing: v.number("spacing").map { CGFloat($0) },
                        pinnedViews: v.pick(
                            "pinnedViews", from: [[.sectionHeaders], [.sectionHeaders, .sectionFooters]])
                            ?? PinnedScrollableViews()
                    ) {
                        Section {
                            ForEach(1...20, id: \.self) { i in
                                Text("行 \(i)")
                                    .frame(width: i % 2 == 0 ? 80 : 160)
                                    .background(.yellow)
                            }
                        } header: {
                            Text("見出し").frame(maxWidth: .infinity).background(.background)
                        } footer: {
                            Text("結び").frame(maxWidth: .infinity).background(.background)
                        }
                    }
                }
            )
        }
    )
}
