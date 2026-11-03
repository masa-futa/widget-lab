import SwiftUI

nonisolated extension CatalogEntry {
    static let labelsVisibility = CatalogEntry(
        id: "labelsVisibility",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にあるコントロールの名前（ラベル）を出すか隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labelsvisibility(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "labelsVisibility", .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2),
                on: true, summary: "名前の出し方。.hidden は labelsHidden() と同じ")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Toggle(\"通知\", isOn: $isOn)\n    Picker(\"果物\", selection: $fruit) {\n"
                + "        Text(\"りんご\").tag(\"りんご\")\n        Text(\"みかん\").tag(\"みかん\")\n    }\n}"),
        build: { v in
            AnyView(
                LabelsVisibilityDemo(
                    visibility: v.pick("labelsVisibility", from: [Visibility.automatic, .visible, .hidden])))
        }
    )
}

private struct LabelsVisibilityDemo: View {
    let visibility: Visibility?
    @State private var isOn = true
    @State private var fruit = "りんご"

    var body: some View {
        VStack {
            Toggle("通知", isOn: $isOn)
            Picker("果物", selection: $fruit) {
                Text("りんご").tag("りんご")
                Text("みかん").tag("みかん")
            }
        }
        .apply(visibility) { $0.labelsVisibility($1) }
        .frame(width: 240)
    }
}
