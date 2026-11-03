import SwiftUI

nonisolated extension CatalogEntry {
    static let textRenderer = CatalogEntry(
        id: "textRenderer",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の描き方を、自分で書いた TextRenderer に任せる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/textrenderer(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "textRenderer",
                .choice(
                    [Choice("波", code: "WaveRenderer()"), Choice("影", code: "ShadowRenderer()")], initial: 0),
                on: true, summary: "描き方（波: 字ごとに上下にずらす、影: 赤い影を足す）")
        ],
        code: CodeTemplate(
            prefix: ["// WaveRenderer・ShadowRenderer: draw(layout:in:) で字や行を描く TextRenderer"], call: "Text",
            fixedArguments: ["\"文字の描き方を変える\""], suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                Text("文字の描き方を変える")
                    .apply(v.pick("textRenderer", from: [true, false])) { view, isWave in
                        if isWave {
                            view.textRenderer(WaveRenderer())
                        } else {
                            view.textRenderer(ShadowRenderer())
                        }
                    }
                    .font(.title)
            )
        }
    )
}

/// 字ごとに上下にずらして、波のように描く
nonisolated private struct WaveRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            for run in line {
                for (index, glyph) in run.enumerated() {
                    var copy = ctx
                    copy.translateBy(x: 0, y: sin(Double(index) * 0.9) * 6)
                    copy.draw(glyph)
                }
            }
        }
    }
}

/// 行ごとに、右下へずらした赤い影を足して描く
nonisolated private struct ShadowRenderer: TextRenderer {
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            var copy = ctx
            copy.addFilter(.shadow(color: .red, radius: 0, x: 3, y: 3))
            copy.draw(line)
        }
    }
}
