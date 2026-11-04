import SwiftUI

nonisolated extension CatalogEntry {
    static let backgroundPreferenceValue = CatalogEntry(
        id: "backgroundPreferenceValue",
        kind: .modifier,
        topic: .preferences,
        summary: "子が知らせた値を読み、元の View の後ろに別の View を描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/backgroundpreferencevalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "backgroundPreferenceValue", id: "backgroundPreferenceValue.key", label: nil,
                .fixed(code: "BoundsKey.self"),
                required: true, summary: "読む値の種類（PreferenceKey）"),
            .modifier(
                "backgroundPreferenceValue", id: "backgroundPreferenceValue.transform", label: nil,
                .fixed(code: "{ Marker(anchor: $0) }"), on: true,
                summary: "読んだ値から、後ろに描く View を作る。ここでは「ぶどう」の枠に印を描く"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Text(\"りんご\")\n    Text(\"ぶどう\")\n        .anchorPreference(key: BoundsKey.self, value: .bounds, transform: { $0 })\n    Text(\"もも\")\n}",
            closing: PreferenceCode.boundsKey + PreferenceCode.marker(fills: true)),
        build: { v in
            AnyView(BackgroundPreferenceValueDemo(marks: v["backgroundPreferenceValue.transform"] != nil))
        }
    )
}

private struct BackgroundPreferenceValueDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            FruitTag("りんご")
            FruitTag("ぶどう")
                .anchorPreference(key: DemoBoundsKey.self, value: .bounds, transform: { $0 })
            FruitTag("もも")
        }
        .apply(marks ? () : nil) { view, _ in
            view.backgroundPreferenceValue(DemoBoundsKey.self) { PreferenceMarker(anchor: $0, fills: true) }
        }
    }
}
