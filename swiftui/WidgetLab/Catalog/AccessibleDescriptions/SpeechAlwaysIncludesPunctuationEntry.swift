import SwiftUI

nonisolated extension CatalogEntry {
    static let speechAlwaysIncludesPunctuation = CatalogEntry(
        id: "speechAlwaysIncludesPunctuation",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "VoiceOver が文の句読点や記号を、いつもすべて読むようにする modifier。記号に意味がある文に付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/speechalwaysincludespunctuation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechAlwaysIncludesPunctuation", .toggle(initial: true), on: true,
                summary: "true なら記号もすべて読む")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"a + b = 10;\""]),
        build: { v in
            AnyView(PunctuationDemo(includes: v.flag("speechAlwaysIncludesPunctuation")))
        }
    )
}

private struct PunctuationDemo: View {
    /// nil なら modifier をかけない
    let includes: Bool?

    var body: some View {
        A11yDemo(
            title: "VoiceOver の読み方",
            lines: [
                A11yText.element("a + b = 10;"),
                includes == true ? "＋・＝・；もすべて読む" : "記号は、VoiceOver の設定（句読点）に従って読む",
            ]
        ) {
            Text("a + b = 10;")
                .font(.title3.monospaced())
                .apply(includes) { view, includes in
                    view.speechAlwaysIncludesPunctuation(includes)
                }
        }
    }
}
