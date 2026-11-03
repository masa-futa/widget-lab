import SwiftUI

nonisolated extension CatalogEntry {
    static let layerEffect = CatalogEntry(
        id: "layerEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を 1 枚の絵（Layer）にしてシェーダーに渡し、ほかの点の色も使って描き直す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/layereffect(_:maxsampleoffset:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layerEffect", id: "layerEffect.shader",
                .choice(
                    [
                        Choice("細かい升", code: "ShaderLibrary.pixelate(.float(6))"),
                        Choice("粗い升", code: "ShaderLibrary.pixelate(.float(14))"),
                    ],
                    initial: 0),
                required: true, summary: "かけるシェーダー（升の大きさ）"),
            .modifier(
                "layerEffect", id: "layerEffect.maxSampleOffset", label: "maxSampleOffset",
                .fixed(code: "CGSize(width: 7, height: 7)"),
                required: true, summary: "元の場所から、どれだけ離れた点の色を取るか（の上限）"),
            .modifier(
                "layerEffect", id: "layerEffect.isEnabled", label: "isEnabled", .toggle(initial: true), on: true,
                summary: "効果をかけるか（false なら元のまま）"),
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"car.fill\")", "    .font(.system(size: 80))"], call: ".foregroundStyle",
            fixedArguments: [".blue"]),
        build: { v in
            let shader = v.pick(
                "layerEffect.shader", from: [ShaderLibrary.pixelate(.float(6)), ShaderLibrary.pixelate(.float(14))])
            return AnyView(
                Image(systemName: "car.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)
                    .apply(v.flag("layerEffect.isEnabled")) {
                        $0.layerEffect(
                            shader ?? ShaderLibrary.pixelate(.float(6)), maxSampleOffset: CGSize(width: 7, height: 7),
                            isEnabled: $1)
                    }
            )
        }
    )
}
