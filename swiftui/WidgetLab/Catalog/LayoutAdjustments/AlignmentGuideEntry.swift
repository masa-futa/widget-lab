import SwiftUI

nonisolated extension CatalogEntry {
    static let alignmentGuide = CatalogEntry(
        id: "alignmentGuide",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "並びで揃えるときに使う位置（揃えの線）を、View ごとに変える modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/alignmentguide(_:computevalue:)-6y3u2")!,
        stage: .card,
        properties: [
            .modifier(
                "alignmentGuide", id: "alignmentGuide.g", .fixed(code: ".leading"), required: true,
                summary: "変える揃えの線（並びの alignment と同じもの）"),
            .modifier(
                "alignmentGuide", id: "alignmentGuide.computeValue", label: "computeValue",
                .choice(
                    [
                        Choice("右へ 40", code: "{ d in d[.leading] - 40 }"),
                        Choice("左へ 20", code: "{ d in d[.leading] + 20 }"),
                        Choice("幅の半分", code: "{ d in d.width / 2 }"),
                    ],
                    initial: 0),
                on: true, summary: "揃えの線の位置を、View の大きさ（d）から計算する"),
        ],
        code: CodeTemplate(
            prefix: ["VStack(alignment: .leading) {", "    Text(\"上の行\")"], call: "Text", fixedArguments: ["\"ずらす行\""],
            suffix: [".background(.yellow)"], closing: ["    Text(\"下の行\")", "}"]),
        build: { v in
            let compute = v.pick(
                "alignmentGuide.computeValue",
                from: [
                    { (d: ViewDimensions) in d[.leading] - 40 }, { (d: ViewDimensions) in d[.leading] + 20 },
                    { (d: ViewDimensions) in d.width / 2 },
                ])
            return AnyView(
                VStack(alignment: .leading) {
                    Text("上の行")
                    Text("ずらす行")
                        .apply(compute) { $0.alignmentGuide(.leading, computeValue: $1) }
                        .background(.yellow)
                    Text("下の行")
                }
                .border(.secondary)
            )
        }
    )
}
