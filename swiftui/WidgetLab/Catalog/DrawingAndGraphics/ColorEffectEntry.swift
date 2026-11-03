import SwiftUI

nonisolated extension CatalogEntry {
    static let colorEffect = CatalogEntry(
        id: "colorEffect",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "点ごとの色を、Metal のシェーダーで計算し直して描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/coloreffect(_:isenabled:)")!,
        stage: .card,
        properties: [
            .modifier(
                "colorEffect", id: "colorEffect.shader",
                .choice(
                    [
                        Choice("細い縞", code: "ShaderLibrary.stripes(.float(6))"),
                        Choice("太い縞", code: "ShaderLibrary.stripes(.float(16))"),
                        Choice("白と黒", code: "ShaderLibrary.threshold(.float(0.5))"),
                    ],
                    initial: 0),
                required: true, summary: "かけるシェーダー（Shaders.metal の関数と引数）"),
            .modifier(
                "colorEffect", id: "colorEffect.isEnabled", label: "isEnabled", .toggle(initial: true), on: true,
                summary: "効果をかけるか（false なら元のまま）"),
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            let shader = v.pick(
                "colorEffect.shader",
                from: [
                    ShaderLibrary.stripes(.float(6)), ShaderLibrary.stripes(.float(16)),
                    ShaderLibrary.threshold(.float(0.5)),
                ])
            return AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.flag("colorEffect.isEnabled")) {
                        $0.colorEffect(shader ?? ShaderLibrary.stripes(.float(6)), isEnabled: $1)
                    }
            )
        }
    )
}
