import SwiftUI

nonisolated extension CatalogEntry {
    static let speechSpellsOutCharacters = CatalogEntry(
        id: "speechSpellsOutCharacters",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "VoiceOver が文を 1 文字ずつ区切って読むようにする modifier。確認のコードや型番に付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/speechspellsoutcharacters(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechSpellsOutCharacters", .toggle(initial: true), on: true,
                summary: "true なら 1 文字ずつ読む")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"XK7-29Q\""]),
        build: { v in
            AnyView(SpellsOutDemo(spells: v.flag("speechSpellsOutCharacters")))
        }
    )
}

private struct SpellsOutDemo: View {
    /// nil なら modifier をかけない
    let spells: Bool?

    var body: some View {
        A11yDemo(
            title: "VoiceOver の読み方",
            lines: [spells == true ? "X、K、7、ハイフン、2、9、Q と 1 文字ずつ読む" : "ひと続きの言葉として読む（数字はまとめて読むことがある）"]
        ) {
            Text("XK7-29Q")
                .font(.title2.monospaced())
                .apply(spells) { view, spells in
                    view.speechSpellsOutCharacters(spells)
                }
        }
    }
}
