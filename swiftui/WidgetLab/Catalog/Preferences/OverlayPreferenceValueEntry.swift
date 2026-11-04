import SwiftUI

nonisolated extension CatalogEntry {
    static let overlayPreferenceValue = CatalogEntry(
        id: "overlayPreferenceValue",
        kind: .modifier,
        topic: .preferences,
        summary: "子が知らせた値を読み、元の View の上に別の View を重ねる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/overlaypreferencevalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "overlayPreferenceValue", id: "overlayPreferenceValue.key", label: nil, .fixed(code: "BoundsKey.self"),
                required: true, summary: "読む値の種類（PreferenceKey）"),
            .modifier(
                "overlayPreferenceValue", id: "overlayPreferenceValue.transform", label: nil,
                .fixed(code: "{ Marker(anchor: $0) }"), on: true,
                summary: "読んだ値から、上に描く View を作る。ここでは「ぶどう」の枠に印を描く"),
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Text(\"りんご\")\n    Text(\"ぶどう\")\n        .anchorPreference(key: BoundsKey.self, value: .bounds, transform: { $0 })\n    Text(\"もも\")\n}",
            closing: PreferenceCode.boundsKey + PreferenceCode.marker(fills: false)),
        build: { v in
            AnyView(OverlayPreferenceValueDemo(marks: v["overlayPreferenceValue.transform"] != nil))
        }
    )
}

private struct OverlayPreferenceValueDemo: View {
    let marks: Bool

    var body: some View {
        HStack {
            FruitTag("りんご")
            FruitTag("ぶどう")
                .anchorPreference(key: DemoBoundsKey.self, value: .bounds, transform: { $0 })
            FruitTag("もも")
        }
        .apply(marks ? () : nil) { view, _ in
            view.overlayPreferenceValue(DemoBoundsKey.self) { PreferenceMarker(anchor: $0, fills: false) }
        }
    }
}
