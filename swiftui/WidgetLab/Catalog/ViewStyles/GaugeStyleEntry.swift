import SwiftUI

nonisolated extension CatalogEntry {
    static let gaugeStyle = CatalogEntry(
        id: "gaugeStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Gauge の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/gaugestyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "gaugeStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".linearCapacity"), Choice(".accessoryLinear"),
                        Choice(".accessoryLinearCapacity"), Choice(".accessoryCircular"),
                        Choice(".accessoryCircularCapacity"),
                    ],
                    initial: 5),
                on: true, summary: "Gauge の見た目のスタイル"),
            .modifier("tint", .color(initial: 3), summary: "目盛りの色"),
        ],
        code: CodeTemplate(
            call: "Gauge", fixedArguments: ["value: 0.6"],
            trailing: " {\n    Text(\"電池\")\n} currentValueLabel: {\n    Text(\"60\")\n}"),
        build: { v in
            AnyView(
                Gauge(value: 0.6) {
                    Text("電池")
                } currentValueLabel: {
                    Text("60")
                }
                .apply(v.pick("gaugeStyle", from: GaugeStyleDemo.Style.allCases)) { GaugeStyleDemo.styled($0, $1) }
                .apply(v.color("tint")) { $0.tint($1) }
                .frame(width: 240)
            )
        }
    )
}

private enum GaugeStyleDemo {
    enum Style: CaseIterable {
        case automatic, linearCapacity, accessoryLinear, accessoryLinearCapacity, accessoryCircular
        case accessoryCircularCapacity
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
