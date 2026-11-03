import SwiftUI

nonisolated extension CatalogEntry {
    static let frame = CatalogEntry(
        id: "frame",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View を決めた大きさ、または伸び縮みの範囲の枠に入れる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/frame(width:height:alignment:)")!,
        stage: .card,
        properties: [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...240, step: 20, initial: 160), on: true,
                summary: "枠の幅"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 20...160, step: 10, initial: 60),
                summary: "枠の高さ"),
            .modifier(
                "frame", id: "frame.alignment", label: "alignment",
                .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0), on: true,
                summary: "枠の中の揃え方"),
            .modifier(
                "frame", id: "frame.maxWidth", label: "maxWidth", line: "frame.max", .fixed(code: ".infinity"),
                summary: "伸ばせる幅の上限（.infinity で置き場所いっぱいに伸びる）。決めた大きさの枠の外にもう 1 つ枠をかける"),
            .modifier(
                "frame", id: "frame.maxHeight", label: "maxHeight", line: "frame.max", .fixed(code: ".infinity"),
                summary: "伸ばせる高さの上限"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"見本\""], suffix: [".background(.yellow)"]),
        build: { v in
            let width = v.number("frame.width").map { CGFloat($0) }
            let height = v.number("frame.height").map { CGFloat($0) }
            let alignment = v.pick("frame.alignment", from: [Alignment.leading, .center, .trailing])
            let maxWidth: CGFloat? = v.flag("frame.maxWidth") != nil ? .infinity : nil
            let maxHeight: CGFloat? = v.flag("frame.maxHeight") != nil ? .infinity : nil
            let hasFixed = width != nil || height != nil || alignment != nil
            let hasMax = maxWidth != nil || maxHeight != nil
            return AnyView(
                Text("見本")
                    .apply(hasFixed ? alignment ?? .center : nil) {
                        $0.frame(width: width, height: height, alignment: $1)
                    }
                    .apply(hasMax ? () : nil) { view, _ in view.frame(maxWidth: maxWidth, maxHeight: maxHeight) }
                    .background(.yellow)
            )
        }
    )
}
