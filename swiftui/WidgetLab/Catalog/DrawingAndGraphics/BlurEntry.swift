import SwiftUI

nonisolated extension CatalogEntry {
    static let blur = CatalogEntry(
        id: "blur",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View をぼかして描く modifier（ガウスぼかし）。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/blur(radius:opaque:)")!,
        stage: .card,
        properties: [
            .modifier("blur", label: "radius", .slider(range: 0...20, step: 1, initial: 4), on: true, summary: "ぼかしの半径")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .font(.system(size: 48, weight: .bold))"], call: ".background",
            fixedArguments: [".yellow"]),
        build: { v in
            AnyView(
                Text("見本")
                    .font(.system(size: 48, weight: .bold))
                    .background(.yellow)
                    .apply(v.number("blur")) { $0.blur(radius: $1) }
            )
        }
    )
}
