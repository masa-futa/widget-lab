import SwiftUI

nonisolated extension CatalogEntry {
    static let distortionEffect = CatalogEntry(
        id: "distortionEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "点ごとに、色を取ってくる場所を Metal のシェーダーで計算し、View をゆがめて描く modifier。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/distortioneffect(_:maxsampleoffset:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "distortionEffect", id: "distortionEffect.shader",
                .choice(
                    [
                        Choice("小さい波", code: "ShaderLibrary.wave(.float(4), .float(40))"),
                        Choice("大きい波", code: "ShaderLibrary.wave(.float(10), .float(60))"),
                    ],
                    initial: 0),
                required: true, summary: "かけるシェーダー（振れ幅と波長）"),
            .modifier(
                "distortionEffect", id: "distortionEffect.maxSampleOffset", label: "maxSampleOffset",
                .fixed(code: "CGSize(width: 0, height: 10)"), required: true,
                summary: "元の場所から、どれだけ離れた点の色を取るか（の上限）"),
            .modifier(
                "distortionEffect", id: "distortionEffect.isEnabled", label: "isEnabled", .toggle(initial: true),
                on: true, summary: "効果をかけるか（false なら元のまま）"),
        ],
        code: CodeTemplate(
            prefix: ["Text(\"Widget Lab\")", "    .font(.system(size: 40, weight: .bold))"], call: ".padding",
            fixedArguments: [".vertical", "10"]),
        build: { v in
            let shader = v.pick(
                "distortionEffect.shader",
                from: [ShaderLibrary.wave(.float(4), .float(40)), ShaderLibrary.wave(.float(10), .float(60))])
            return AnyView(
                Text("Widget Lab")
                    .font(.system(size: 40, weight: .bold))
                    .padding(.vertical, 10)
                    .apply(v.flag("distortionEffect.isEnabled")) {
                        $0.distortionEffect(
                            shader ?? ShaderLibrary.wave(.float(4), .float(40)),
                            maxSampleOffset: CGSize(width: 0, height: 10), isEnabled: $1)
                    }
            )
        }
    )
}
