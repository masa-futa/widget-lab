import SwiftUI

nonisolated extension CatalogEntry {
    static let meshGradient = CatalogEntry(
        id: "MeshGradient",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "格子の点ごとに色を置き、そのあいだを混ぜて塗るグラデーション。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/meshgradient")!,
        stage: .card,
        properties: [
            .argument(
                "points",
                .choice(
                    [
                        Choice(
                            "等間隔",
                            code: "[[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.5, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]]"
                        ),
                        Choice(
                            "中央を右上へ",
                            code: "[[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.8, 0.2], [1, 0.5], [0, 1], [0.5, 1], [1, 1]]"
                        ),
                    ],
                    initial: 1),
                required: true, summary: "3 × 3 の点の場所（0〜1）"),
            .argument(
                "colors",
                .choice(
                    [
                        Choice("暖色と寒色", code: "[.red, .orange, .yellow, .purple, .white, .green, .blue, .cyan, .mint]"),
                        Choice("青の濃淡", code: "[.indigo, .blue, .cyan, .blue, .white, .cyan, .cyan, .mint, .teal]"),
                    ],
                    initial: 0),
                required: true, summary: "点ごとの色（points と同じ並び）"),
            .argument("smoothsColors", .toggle(initial: false), summary: "色をなめらかに混ぜる（OFF なら true）"),
        ],
        code: CodeTemplate(
            call: "MeshGradient", fixedArguments: ["width: 3", "height: 3"],
            suffix: [".frame(width: 200, height: 120)"]),
        build: { v in
            AnyView(
                MeshGradient(
                    width: 3, height: 3,
                    points: v.pick("points", from: MeshGradientDemo.points) ?? MeshGradientDemo.points[0],
                    colors: v.pick("colors", from: MeshGradientDemo.colors) ?? MeshGradientDemo.colors[0],
                    smoothsColors: v.flag("smoothsColors") ?? true
                )
                .frame(width: 200, height: 120)
            )
        }
    )
}

private enum MeshGradientDemo {
    static let points: [[SIMD2<Float>]] = [
        [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.5, 0.5], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
        [[0, 0], [0.5, 0], [1, 0], [0, 0.5], [0.8, 0.2], [1, 0.5], [0, 1], [0.5, 1], [1, 1]],
    ]
    static let colors: [[Color]] = [
        [.red, .orange, .yellow, .purple, .white, .green, .blue, .cyan, .mint],
        [.indigo, .blue, .cyan, .blue, .white, .cyan, .cyan, .mint, .teal],
    ]
}
