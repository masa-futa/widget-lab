import SwiftUI

nonisolated extension CatalogEntry {
    static let matchedGeometryEffect = CatalogEntry(
        id: "matchedGeometryEffect",
        kind: .modifier,
        topic: .animations,
        summary: "同じ id と名前空間を持つ View どうしで、位置と大きさをそろえる modifier。切り替えると、元の View から動いていく。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/matchedgeometryeffect(id:in:properties:anchor:issource:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.id", label: "id", .fixed(code: "selected"),
                required: true, summary: "そろえる相手の id。選んだ名前の id に合わせる"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.in", label: "in", .fixed(code: "namespace"),
                required: true, summary: "id を探す名前空間（@Namespace）"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.properties", label: "properties",
                .choice([Choice(".frame"), Choice(".position"), Choice(".size")], initial: 0), on: true,
                summary: "そろえるもの。.position は位置だけ、.size は大きさだけ"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.anchor", label: "anchor",
                .choice([Choice(".center"), Choice(".leading"), Choice(".trailing")], initial: 1),
                summary: "位置をそろえる基準の点"),
            .modifier(
                "matchedGeometryEffect", id: "matchedGeometryEffect.isSource", label: "isSource",
                .fixed(code: "false"), required: true,
                summary: "false なら、相手（名前の Text）の枠に自分を合わせる側になる"),
        ],
        code: CodeTemplate(
            prefix: [
                "HStack {",
                "    ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { name in",
                "        Text(name)",
                "            .padding(8)",
                "            .matchedGeometryEffect(id: name, in: namespace)",
                "            .onTapGesture { withAnimation { selected = name } }",
                "    }",
                "}",
                ".background {",
                "    Capsule()",
            ],
            indent: 8, call: ".fill", fixedArguments: [".yellow"], closing: ["}"]),
        build: { v in
            let hasArguments = v["matchedGeometryEffect.properties"] != nil || v["matchedGeometryEffect.anchor"] != nil
            return AnyView(
                MatchedGeometryDemo(
                    matching: hasArguments
                        ? MatchedGeometryDemo.Matching(
                            properties: v.pick(
                                "matchedGeometryEffect.properties",
                                from: [MatchedGeometryProperties.frame, .position, .size]) ?? .frame,
                            anchor: v.pick(
                                "matchedGeometryEffect.anchor", from: [UnitPoint.center, .leading, .trailing])
                                ?? .center)
                        : nil))
        }
    )
}
