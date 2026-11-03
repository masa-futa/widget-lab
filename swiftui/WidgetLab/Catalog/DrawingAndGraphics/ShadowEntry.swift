import SwiftUI

nonisolated extension CatalogEntry {
    static let shadow = CatalogEntry(
        id: "shadow",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の後ろに影を描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/shadow(color:radius:x:y:)")!,
        stage: .card,
        properties: [
            .modifier(
                "shadow", id: "shadow.color", label: "color", .color(initial: 7), on: true,
                summary: "影の色（OFF なら半透明の黒）"),
            .modifier(
                "shadow", id: "shadow.radius", label: "radius", .slider(range: 0...20, step: 2, initial: 8),
                required: true, summary: "影のぼかしの半径"),
            .modifier(
                "shadow", id: "shadow.x", label: "x", .slider(range: -20...20, step: 2, initial: 8), on: true,
                summary: "影を横にずらす距離"),
            .modifier(
                "shadow", id: "shadow.y", label: "y", .slider(range: -20...20, step: 2, initial: 8), on: true,
                summary: "影を縦にずらす距離"),
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 16)", "    .fill(.yellow)"], call: ".frame",
            fixedArguments: ["width: 160", "height: 80"]),
        build: { v in
            let color = v.color("shadow.color")
            let x = v.number("shadow.x").map { CGFloat($0) }
            let y = v.number("shadow.y").map { CGFloat($0) }
            let hasShadow = color != nil || x != nil || y != nil
            return AnyView(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.yellow)
                    .frame(width: 160, height: 80)
                    .apply(hasShadow ? () : nil) { view, _ in
                        view.shadow(
                            color: color ?? Color(.sRGBLinear, white: 0, opacity: 0.33),
                            radius: CGFloat(v.number("shadow.radius") ?? 0), x: x ?? 0, y: y ?? 0)
                    }
            )
        }
    )
}
