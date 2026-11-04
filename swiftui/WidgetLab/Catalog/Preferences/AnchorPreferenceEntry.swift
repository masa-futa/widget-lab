import SwiftUI

nonisolated extension CatalogEntry {
    static let anchorPreference = CatalogEntry(
        id: "anchorPreference",
        kind: .modifier,
        topic: .preferences,
        summary: "子の枠や位置（anchor）を、親へ知らせる modifier。親は自分の座標に直して、印などを描ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/anchorpreference(key:value:transform:)")!,
        stage: .card,
        properties: [
            .modifier(
                "anchorPreference", id: "anchorPreference.key", label: "key", .fixed(code: "BoundsKey.self"),
                required: true, summary: "知らせる値の種類（PreferenceKey）"),
            .modifier(
                "anchorPreference", id: "anchorPreference.value", label: "value", .fixed(code: ".bounds"),
                required: true, summary: "知らせる形。.bounds は枠ぜんたい"),
            .modifier(
                "anchorPreference", id: "anchorPreference.transform", label: "transform", .fixed(code: "{ $0 }"),
                on: true, summary: "anchor を知らせる値に変える関数。外すと、親は印を描けない"),
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"りんご\")"], call: "Text", fixedArguments: ["\"ぶどう\""],
            closing: [
                "    Text(\"もも\")", "}",
                ".overlayPreferenceValue(BoundsKey.self) { Marker(anchor: $0) }",
            ]
                + PreferenceCode.boundsKey + PreferenceCode.marker(fills: false)),
        build: { v in
            AnyView(AnchorPreferenceDemo(marks: v["anchorPreference.transform"] != nil))
        }
    )
}

private struct AnchorPreferenceDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            FruitTag("りんご")
            FruitTag("ぶどう")
                .apply(marks ? () : nil) { view, _ in
                    view.anchorPreference(key: DemoBoundsKey.self, value: .bounds, transform: { $0 })
                }
            FruitTag("もも")
        }
        .overlayPreferenceValue(DemoBoundsKey.self) { PreferenceMarker(anchor: $0) }
    }
}
