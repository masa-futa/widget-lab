import SwiftUI

nonisolated extension CatalogEntry {
    static let gauge = CatalogEntry(
        id: "Gauge",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "範囲の中で、今の値がどこにあるかを示す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/gauge")!,
        stage: .card,
        properties: [
            .argument("value", .slider(range: 0...1, step: 0.1, initial: 0.4), required: true, summary: "今の値"),
            .modifier(
                "gaugeStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".linearCapacity"), Choice(".accessoryLinear"),
                        Choice(".accessoryLinearCapacity"), Choice(".accessoryCircular"),
                        Choice(".accessoryCircularCapacity"),
                    ],
                    initial: 4),
                on: true, summary: "見た目のスタイル。accessory はロック画面のウィジェットと同じ形"),
            .modifier("tint", .color(initial: 3), summary: "目盛りの色"),
        ],
        code: CodeTemplate(
            call: "Gauge",
            trailing: " {\n    Text(\"電池\")\n} currentValueLabel: {\n    Image(systemName: \"bolt.fill\")\n}"),
        build: { v in
            AnyView(
                Gauge(value: v.number("value") ?? 0) {
                    Text("電池")
                } currentValueLabel: {
                    Image(systemName: "bolt.fill")
                }
                .apply(v.pick("gaugeStyle", from: GaugeDemo.Style.allCases)) { GaugeDemo.styled($0, $1) }
                .apply(v.color("tint")) { $0.tint($1) }
                .frame(maxWidth: 260)
            )
        }
    )
}

private enum GaugeDemo {
    enum Style: CaseIterable {
        case automatic, linearCapacity, accessoryLinear, accessoryLinearCapacity, accessoryCircular,
            accessoryCircularCapacity
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.gaugeStyle(.automatic)
        case .linearCapacity: view.gaugeStyle(.linearCapacity)
        case .accessoryLinear: view.gaugeStyle(.accessoryLinear)
        case .accessoryLinearCapacity: view.gaugeStyle(.accessoryLinearCapacity)
        case .accessoryCircular: view.gaugeStyle(.accessoryCircular)
        case .accessoryCircularCapacity: view.gaugeStyle(.accessoryCircularCapacity)
        }
    }
}
