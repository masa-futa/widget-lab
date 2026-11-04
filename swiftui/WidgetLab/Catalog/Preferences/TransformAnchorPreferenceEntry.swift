import SwiftUI

nonisolated extension CatalogEntry {
    static let transformAnchorPreference = CatalogEntry(
        id: "transformAnchorPreference",
        kind: .modifier,
        topic: .preferences,
        summary: "子の枠や位置（anchor）で、すでにある値を書き換えて親へ知らせる modifier。いくつもの子の枠を 1 つの配列に集められる。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/transformanchorpreference(key:value:transform:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "transformAnchorPreference", id: "transformAnchorPreference.key", label: "key",
                .fixed(code: "AllBoundsKey.self"), required: true, summary: "知らせる値の種類（PreferenceKey）"),
            .modifier(
                "transformAnchorPreference", id: "transformAnchorPreference.value", label: "value",
                .fixed(code: ".bounds"), required: true, summary: "知らせる形。.bounds は枠ぜんたい"),
            .modifier(
                "transformAnchorPreference", id: "transformAnchorPreference.transform", label: "transform",
                .fixed(code: "{ $0.append($1) }"), on: true,
                summary: "すでにある値（配列）に、この子の anchor を足す関数。外すと、親は印を描けない"),
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    ForEach([\"りんご\", \"ぶどう\", \"もも\"], id: \\.self) { name in"], indent: 8,
            call: "Text", fixedArguments: ["name"],
            closing: [
                "    }",
                "}",
                ".overlayPreferenceValue(AllBoundsKey.self) { anchors in",
                "    ForEach(anchors.indices, id: \\.self) { Marker(anchor: anchors[$0]) }",
                "}",
                "",
                "struct AllBoundsKey: PreferenceKey {",
                "    static var defaultValue: [Anchor<CGRect>] { [] }",
                "    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {",
                "        value += nextValue()",
                "    }",
                "}",
            ] + PreferenceCode.marker(fills: false)),
        build: { v in
            AnyView(TransformAnchorPreferenceDemo(marks: v["transformAnchorPreference.transform"] != nil))
        }
    )
}

private struct TransformAnchorPreferenceDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            ForEach(["りんご", "ぶどう", "もも"], id: \.self) { name in
                FruitTag(name)
                    .apply(marks ? () : nil) { view, _ in
                        view.transformAnchorPreference(key: DemoAllBoundsKey.self, value: .bounds) { $0.append($1) }
                    }
            }
        }
        .overlayPreferenceValue(DemoAllBoundsKey.self) { anchors in
            ForEach(anchors.indices, id: \.self) { PreferenceMarker(anchor: anchors[$0]) }
        }
    }
}
