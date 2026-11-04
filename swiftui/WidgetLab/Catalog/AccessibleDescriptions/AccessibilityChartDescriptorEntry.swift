import Accessibility
import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityChartDescriptor = CatalogEntry(
        id: "accessibilityChartDescriptor",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "グラフの題名・軸・データを支援技術に渡す modifier。VoiceOver のオーディオグラフで、値を音の高さで聞ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitychartdescriptor(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityChartDescriptor", .fixed(code: "StepsChart()"), on: true,
                summary: "グラフの中身（AXChartDescriptorRepresentable）。VoiceOver のローターで「オーディオグラフ」を選んで聞く")
        ],
        code: CodeTemplate(
            prefix: [
                "HStack(alignment: .bottom) {", "    ForEach(days) { day in",
                "        Rectangle().frame(width: 24, height: day.steps / 50)", "    }", "}",
                ".accessibilityElement()",
            ], indent: 0, call: ".accessibilityLabel", fixedArguments: ["\"歩数\""],
            closing: [
                "", "struct StepsChart: AXChartDescriptorRepresentable {",
                "    func makeChartDescriptor() -> AXChartDescriptor {",
                "        let x = AXCategoricalDataAxisDescriptor(title: \"曜日\", categoryOrder: [\"月\", \"火\", \"水\"])",
                "        let y = AXNumericDataAxisDescriptor(title: \"歩数\", range: 0...5000, gridlinePositions: []) { \"\\(Int($0)) 歩\" }",
                "        let points = [AXDataPoint(x: \"月\", y: 3000), AXDataPoint(x: \"火\", y: 5000), AXDataPoint(x: \"水\", y: 2000)]",
                "        let series = AXDataSeriesDescriptor(name: \"歩数\", isContinuous: false, dataPoints: points)",
                "        return AXChartDescriptor(title: \"1 週間の歩数\", summary: nil, xAxis: x, yAxis: y, additionalAxes: [], series: [series])",
                "    }", "}",
            ]),
        build: { v in
            AnyView(ChartDescriptorDemo(describes: v["accessibilityChartDescriptor"] != nil))
        }
    )
}

private struct ChartDescriptorDemo: View {
    let describes: Bool
    private let days = [(name: "月", steps: 3000.0), (name: "火", steps: 5000), (name: "水", steps: 2000)]

    var body: some View {
        A11yDemo(title: "VoiceOver に渡るグラフの中身", lines: lines) {
            HStack(alignment: .bottom) {
                ForEach(days, id: \.name) { day in
                    Rectangle()
                        .fill(.blue)
                        .frame(width: 24, height: day.steps / 50)
                }
            }
            .accessibilityElement()
            .accessibilityLabel("歩数")
            .apply(describes ? () : nil) { view, _ in
                view.accessibilityChartDescriptor(StepsChart())
            }
        }
    }

    private var lines: [String] {
        describes
            ? ["「1 週間の歩数」 横の軸: 曜日・縦の軸: 歩数", "ローターの「オーディオグラフ」で、月 3,000・火 5,000・水 2,000 を音で聞ける"]
            : [A11yText.element("歩数"), "（グラフの中身は伝わらない）"]
    }
}

private struct StepsChart: AXChartDescriptorRepresentable {
    func makeChartDescriptor() -> AXChartDescriptor {
        let x = AXCategoricalDataAxisDescriptor(title: "曜日", categoryOrder: ["月", "火", "水"])
        let y = AXNumericDataAxisDescriptor(title: "歩数", range: 0...5000, gridlinePositions: []) { "\(Int($0)) 歩" }
        let points = [AXDataPoint(x: "月", y: 3000), AXDataPoint(x: "火", y: 5000), AXDataPoint(x: "水", y: 2000)]
        let series = AXDataSeriesDescriptor(name: "歩数", isContinuous: false, dataPoints: points)
        return AXChartDescriptor(
            title: "1 週間の歩数", summary: nil, xAxis: x, yAxis: y, additionalAxes: [], series: [series])
    }
}
