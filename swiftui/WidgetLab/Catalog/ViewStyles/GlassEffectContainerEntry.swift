import SwiftUI

nonisolated extension CatalogEntry {
    static let glassEffectContainer = CatalogEntry(
        id: "GlassEffectContainer",
        kind: .view,
        topic: .viewStyles,
        summary: "中の Liquid Glass の形をまとめて描き、近い形どうしを 1 つに溶け合わせる入れ物。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/glasseffectcontainer")!,
        stage: .card,
        properties: [
            .argument(
                "spacing", .slider(range: 0...60, step: 10, initial: 40), on: true,
                summary: "この距離より近い形を溶け合わせる（省くと既定の距離）")
        ],
        code: CodeTemplate(
            call: "GlassEffectContainer",
            trailing: " {\n    HStack(spacing: 20) {\n        Image(systemName: \"pencil\")\n"
                + "            .frame(width: 56, height: 56)\n            .glassEffect()\n"
                + "        Image(systemName: \"eraser\")\n            .frame(width: 56, height: 56)\n"
                + "            .glassEffect()\n    }\n    .font(.title2)\n}"),
        build: { v in
            AnyView(
                GlassEffectContainerDemo.container(spacing: v.number("spacing"))
                    .padding()
                    .background(
                        LinearGradient(colors: [.orange, .pink, .blue], startPoint: .leading, endPoint: .trailing))
            )
        }
    )
}

private enum GlassEffectContainerDemo {
    @ViewBuilder
    static func container(spacing: Double?) -> some View {
        if let spacing {
            GlassEffectContainer(spacing: spacing) { shapes }
        } else {
            GlassEffectContainer { shapes }
        }
    }

    private static var shapes: some View {
        HStack(spacing: 20) {
            Image(systemName: "pencil")
                .frame(width: 56, height: 56)
                .glassEffect()
            Image(systemName: "eraser")
                .frame(width: 56, height: 56)
                .glassEffect()
        }
        .font(.title2)
    }
}
