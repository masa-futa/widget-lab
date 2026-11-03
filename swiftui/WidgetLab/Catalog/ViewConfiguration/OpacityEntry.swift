import SwiftUI

nonisolated extension CatalogEntry {
    static let opacity = CatalogEntry(
        id: "opacity",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "View の不透明度を決める modifier。0 で見えなくなるが、場所は取ったまま。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/opacity(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "opacity", .slider(range: 0...1, step: 0.1, initial: 0.3), on: true, summary: "不透明度（0 で透明、1 でそのまま）")
        ],
        code: CodeTemplate(call: "Image", fixedArguments: ["systemName: \"star.fill\""]),
        build: { v in
            AnyView(
                Image(systemName: "star.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.orange)
                    .apply(v.number("opacity")) { $0.opacity($1) }
            )
        }
    )
}
