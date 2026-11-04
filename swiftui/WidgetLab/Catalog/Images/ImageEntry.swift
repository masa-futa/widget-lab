import SwiftUI

nonisolated extension CatalogEntry {
    static let image = CatalogEntry(
        id: "Image",
        kind: .view,
        topic: .images,
        summary: "画像を表示する View。SF Symbols の記号は systemName で名前を渡す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/image")!,
        stage: .card,
        properties: [
            .argument(
                "systemName",
                .choice(
                    [Choice("\"wifi\""), Choice("\"speaker.wave.3.fill\""), Choice("\"chart.bar.fill\"")], initial: 0),
                required: true, summary: "SF Symbols の記号の名前"),
            .argument(
                "variableValue", .slider(range: 0...1, step: 0.25, initial: 0.5), on: true,
                summary: "記号の段階の値（0〜1）。対応する記号だけ、値に合わせて一部を薄くする"),
            .modifier("resizable", .fixed(code: ""), on: true, summary: "枠に合わせて大きさを変えられるようにする"),
            .modifier("scaledToFit", .fixed(code: ""), on: true, summary: "縦横の比を保って枠に収める"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "記号の色"),
        ],
        code: CodeTemplate(call: "Image", suffix: [".frame(width: 120, height: 120)"]),
        build: { v in
            AnyView(
                ImageDemo.image(
                    systemName: v.pick("systemName", from: ["wifi", "speaker.wave.3.fill", "chart.bar.fill"]) ?? "wifi",
                    variableValue: v.number("variableValue"), resizable: v["resizable"] != nil
                )
                .apply(v["scaledToFit"] != nil ? () : nil) { view, _ in view.scaledToFit() }
                .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                .frame(width: 120, height: 120)
                .border(.gray.opacity(0.4))
            )
        }
    )
}

private enum ImageDemo {
    static func image(systemName: String, variableValue: Double?, resizable: Bool) -> Image {
        let image = Image(systemName: systemName, variableValue: variableValue)
        return resizable ? image.resizable() : image
    }
}
