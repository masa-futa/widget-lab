import SwiftUI

nonisolated extension CatalogEntry {
    static let onPreferenceChange = CatalogEntry(
        id: "onPreferenceChange",
        kind: .modifier,
        topic: .preferences,
        summary: "子が知らせる値（preference）が変わったときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onpreferencechange(_:perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onPreferenceChange", id: "onPreferenceChange.key", label: nil, .fixed(code: "TitleKey.self"),
                required: true, summary: "見張る値の種類（PreferenceKey）。値は Equatable"),
            .modifier(
                "onPreferenceChange", id: "onPreferenceChange.perform", label: "perform",
                .fixed(code: "{ title = $0 }"),
                on: true, summary: "値が変わったときの処理。果物を変えるたびに記録に出る"),
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Text(\"届いた題名: \\(title)\")\n    Button(\"ぶどうにする\") { fruit = \"ぶどう\" }\n    Text(fruit)\n        .preference(key: TitleKey.self, value: fruit)\n}",
            closing: PreferenceCode.titleKey),
        build: { v in
            AnyView(OnPreferenceChangeDemo(watches: v["onPreferenceChange.perform"] != nil))
        }
    )
}

private struct OnPreferenceChangeDemo: View {
    let watches: Bool
    @State private var fruit = "りんご"
    @State private var title = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            Text("届いた題名: \(title.isEmpty ? "なし" : title)")
            Button(fruit == "りんご" ? "ぶどうにする" : "りんごにする") {
                fruit = fruit == "りんご" ? "ぶどう" : "りんご"
            }
            .buttonStyle(.bordered)
            Text(fruit)
                .preference(key: DemoTitleKey.self, value: fruit)
        }
        .apply(watches ? () : nil) { view, _ in
            view.onPreferenceChange(DemoTitleKey.self) { value in
                title = value
                recorder?.log("題名「\(value)」が届いた")
            }
        }
    }
}
