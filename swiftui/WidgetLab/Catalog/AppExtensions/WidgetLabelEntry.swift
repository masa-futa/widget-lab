import SwiftUI

nonisolated extension CatalogEntry {
    static let widgetLabel = CatalogEntry(
        id: "widgetLabel",
        kind: .modifier,
        topic: .appExtensions,
        summary: "ロック画面などの小さなウィジェットで、本体の外（まわりや下）に添える文を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/widgetlabel(_:)")!,
        noteReason: "アプリ拡張のウィジェットの中で効く。ロック画面や Apple Watch の小さなウィジェット（accessory の大きさ）に置いたときに出る",
        properties: [
            .modifier("widgetLabel", .text(initial: "東京 21°"), on: true, summary: "添える文。丸いウィジェットなら、まわりに沿って出る")
        ],
        code: CodeTemplate(
            prefix: ["// accessoryCircular のウィジェットの中"], indent: 0, call: "Gauge",
            fixedArguments: ["value: 0.7"], trailing: " { Text(\"気温\") }", suffix: [".gaugeStyle(.accessoryCircular)"])
    )
}
