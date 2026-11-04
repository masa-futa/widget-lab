import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityCustomContent = CatalogEntry(
        id: "accessibilityCustomContent",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "要素に詳しい情報を足す modifier。VoiceOver はラベルのあとすぐには読まず、ローターの「詳しい情報」で読む。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitycustomcontent(_:_:importance:)"
        )!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityCustomContent", id: "accessibilityCustomContent.content", label: nil,
                .choice(
                    [Choice("産地", code: "\"産地\", \"青森\""), Choice("値段", code: "\"値段\", \"200 円\"")], initial: 0),
                on: true,
                summary: "情報の名前と中身"),
            .modifier(
                "accessibilityCustomContent", id: "accessibilityCustomContent.importance", label: "importance",
                .choice([Choice(".default"), Choice(".high")], initial: 0), required: true,
                summary: ".high なら、ラベルのあとに続けて読む"),
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"りんご\""]),
        build: { v in
            AnyView(
                CustomContentDemo(
                    content: v.pick("accessibilityCustomContent.content", from: [("産地", "青森"), ("値段", "200 円")]),
                    isHigh: v.pick("accessibilityCustomContent.importance", from: [false, true]) ?? false))
        }
    )
}

private struct CustomContentDemo: View {
    /// nil なら modifier をかけない
    let content: (label: String, value: String)?
    let isHigh: Bool

    var body: some View {
        A11yDemo(title: "VoiceOver が読む要素", lines: lines) {
            Text("りんご")
                .font(.title3)
                .apply(content) { view, content in
                    view.accessibilityCustomContent(
                        LocalizedStringKey(content.label), Text(content.value), importance: isHigh ? .high : .default)
                }
        }
    }

    private var lines: [String] {
        guard let content else { return [A11yText.element("りんご")] }
        return [A11yText.element("りんご")]
            + [isHigh ? "続けて読む: \(content.label) \(content.value)" : "ローターの「詳しい情報」で: \(content.label) \(content.value)"]
    }
}
