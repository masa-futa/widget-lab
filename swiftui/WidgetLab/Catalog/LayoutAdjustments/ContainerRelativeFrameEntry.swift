import SwiftUI

nonisolated extension CatalogEntry {
    static let containerRelativeFrame = CatalogEntry(
        id: "containerRelativeFrame",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "いちばん近い入れ物（ScrollView など）の大きさをもとに、View の枠を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/containerrelativeframe(_:alignment:)")!,
        stage: .card,
        properties: [
            .argument("axes", unlabeled: true, .fixed(code: ".horizontal"), required: true, summary: "大きさを決める向き"),
            .argument(
                "count", unlabeled: true,
                .choice(
                    [
                        Choice("3 等分", code: "count: 3, span: 1, spacing: 8"),
                        Choice("2 等分", code: "count: 2, span: 1, spacing: 8"),
                        Choice("3 等分の 2 つ分", code: "count: 3, span: 2, spacing: 8"),
                    ],
                    initial: 0),
                on: true, summary: "入れ物を count 等分し、span 個分の大きさにする（OFF なら入れ物と同じ大きさ）"),
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                summary: "枠の中の揃え方"),
        ],
        code: CodeTemplate(
            prefix: [
                "ScrollView(.horizontal) {", "    HStack(spacing: 8) {", "        ForEach(1...6, id: \\.self) { i in",
                "            Text(\"\\(i)\")",
            ],
            indent: 16, call: ".containerRelativeFrame", suffix: [".background(.yellow)"],
            closing: ["        }", "    }", "}"]),
        build: { v in
            let split = v.pick("count", from: [(3, 1), (2, 1), (3, 2)])
            let alignment = v.pick("alignment", from: [Alignment.leading, .center, .trailing]) ?? .center
            return AnyView(
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(1...6, id: \.self) { i in
                            ContainerRelativeFrameDemo.framed(Text("\(i)"), split: split, alignment: alignment)
                                .background(.yellow)
                        }
                    }
                }
            )
        }
    )
}

private enum ContainerRelativeFrameDemo {
    @ViewBuilder
    static func framed(_ view: some View, split: (count: Int, span: Int)?, alignment: Alignment) -> some View {
        if let split {
            view.containerRelativeFrame(
                .horizontal, count: split.count, span: split.span, spacing: 8, alignment: alignment)
        } else {
            view.containerRelativeFrame(.horizontal, alignment: alignment)
        }
    }
}
