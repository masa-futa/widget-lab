import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityChildren = CatalogEntry(
        id: "accessibilityChildren",
        kind: .modifier,
        topic: .accessibilityFundamentals,
        summary: "要素の子を、渡した View から作った要素に置き換える modifier。Canvas のように中身を読めない絵に、読める子を足す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitychildren(children:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityChildren", label: "children",
                .fixed(
                    code:
                        "{ HStack { ForEach(days) { day in Rectangle().accessibilityLabel(day.name).accessibilityValue(\"\\(day.steps) 歩\") } } }"
                ), on: true,
                summary: "子の要素を作る View。画面には描かない。棒 1 本ごとに曜日と歩数を読む")
        ],
        code: CodeTemplate(
            prefix: ["Canvas { context, size in", "    drawBars(in: context, size: size)", "}"], indent: 0,
            call: ".accessibilityLabel", fixedArguments: ["\"歩数\""]),
        build: { v in
            AnyView(AccessibilityChildrenDemo(hasChildren: v["accessibilityChildren"] != nil))
        }
    )
}

private struct AccessibilityChildrenDemo: View {
    let hasChildren: Bool
    private let days = [(name: "月", steps: 3000), (name: "火", steps: 5000), (name: "水", steps: 2000)]

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            Canvas { context, size in
                let width = size.width / CGFloat(days.count)
                for (index, day) in days.enumerated() {
                    let height = size.height * CGFloat(day.steps) / 5000
                    let bar = CGRect(
                        x: CGFloat(index) * width + 8, y: size.height - height, width: width - 16, height: height)
                    context.fill(Path(bar), with: .color(.blue))
                }
            }
            .frame(width: 180, height: 90)
            .accessibilityLabel("歩数")
            .apply(hasChildren ? () : nil) { view, _ in
                view.accessibilityChildren {
                    HStack {
                        ForEach(days, id: \.name) { day in
                            Rectangle()
                                .accessibilityLabel(day.name)
                                .accessibilityValue("\(day.steps) 歩")
                        }
                    }
                }
            }
        }
    }

    private var lines: [String] {
        guard hasChildren else { return [A11yText.element("歩数") + "（中の棒は読まない）"] }
        return ["「歩数」の組の中に 3 つ"]
            + A11yText.ordered(days.map { A11yText.element($0.name, value: "\($0.steps.formatted()) 歩") })
    }
}
