import SwiftUI

nonisolated extension CatalogEntry {
    static let safeAreaPadding = CatalogEntry(
        id: "safeAreaPadding",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "安全な領域を狭めて余白を足す modifier。ScrollView なら、中身は余白の下までスクロールできる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/safeareapadding(_:_:)-5wm4i")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice([Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top")], initial: 3),
                on: true, summary: "余白を足す辺（OFF ならすべての辺）"),
            .argument(
                "length", unlabeled: true, .slider(range: 0...80, step: 8, initial: 48), on: true,
                summary: "余白の大きさ（OFF なら環境に合わせた既定の大きさ）"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView {", "    ForEach(1...20, id: \\.self) { i in", "        Text(\"行 \\(i)\")",
                "            .frame(maxWidth: .infinity)", "            .background(.yellow)", "    }", "}",
            ],
            indent: 0, call: ".safeAreaPadding"),
        build: { v in
            AnyView(
                ScrollView {
                    ForEach(1...20, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity)
                            .background(.yellow)
                    }
                }
                .safeAreaPadding(
                    v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top]) ?? .all,
                    v.number("length").map { CGFloat($0) })
            )
        }
    )
}
