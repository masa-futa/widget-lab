import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityTextContentType = CatalogEntry(
        id: "accessibilityTextContentType",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "文がどんな種類か（ソースコード・会話・表計算など）を支援技術に伝える modifier。VoiceOver が読み方を合わせる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilitytextcontenttype(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityTextContentType",
                .choice([Choice(".sourceCode"), Choice(".console"), Choice(".narrative")], initial: 0), on: true,
                summary: "文の種類。外すと .plain（ふつうの文）として読む")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"let total = price * 2\""], suffix: [".monospaced()"]),
        build: { v in
            AnyView(TextContentTypeDemo(type: v.pick("accessibilityTextContentType", from: [0, 1, 2])))
        }
    )
}

private struct TextContentTypeDemo: View {
    /// nil なら modifier をかけない。0 .sourceCode・1 .console・2 .narrative
    let type: Int?

    var body: some View {
        A11yDemo(title: "VoiceOver に伝える文の種類", lines: [line]) {
            Text("let total = price * 2")
                .monospaced()
                .apply(type) { view, type in
                    view.accessibilityTextContentType(
                        [AccessibilityTextContentType.sourceCode, .console, .narrative][type])
                }
        }
    }

    private var line: String {
        switch type {
        case 0: "ソースコード（記号や字下げも伝わるように読む）"
        case 1: "コンソールの出力"
        case 2: "物語の文（続けて読む）"
        default: "ふつうの文（.plain）"
        }
    }
}
