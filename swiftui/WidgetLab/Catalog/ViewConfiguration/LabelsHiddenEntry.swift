import SwiftUI

nonisolated extension CatalogEntry {
    static let labelsHidden = CatalogEntry(
        id: "labelsHidden",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にあるコントロールの名前（ラベル）を隠す modifier。名前は読み上げには残る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labelshidden()")!,
        stage: .card,
        properties: [
            .modifier("labelsHidden", .fixed(code: ""), on: true, summary: "名前を隠す。中のコントロールすべてに効く")
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Toggle(\"通知\", isOn: $isOn)\n    Stepper(\"数\", value: $count)\n}"),
        build: { v in
            AnyView(LabelsHiddenDemo(hidesLabels: v["labelsHidden"] != nil))
        }
    )
}

private struct LabelsHiddenDemo: View {
    let hidesLabels: Bool
    @State private var isOn = true
    @State private var count = 0

    var body: some View {
        VStack {
            Toggle("通知", isOn: $isOn)
            Stepper("数", value: $count)
        }
        .apply(hidesLabels ? () : nil) { view, _ in view.labelsHidden() }
        .frame(width: 240)
    }
}
