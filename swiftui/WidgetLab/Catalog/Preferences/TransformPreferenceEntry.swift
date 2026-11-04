import SwiftUI

nonisolated extension CatalogEntry {
    static let transformPreference = CatalogEntry(
        id: "transformPreference",
        kind: .modifier,
        topic: .preferences,
        summary: "子から上がってきた値を、関数で書き換えてから親へ渡す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transformpreference(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transformPreference",
                .choice(
                    [
                        Choice("後ろに足す", code: "TitleKey.self, { $0 += \"とぶどう\" }"),
                        Choice("置き換える", code: "TitleKey.self, { $0 = \"もも\" }"),
                    ],
                    initial: 0),
                on: true, summary: "書き換える値の種類と、書き換える関数。子が知らせた「りんご」を元に変える")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"届いた題名: \\(title)\")", "    Text(\"子\")"], indent: 8,
            call: ".preference", fixedArguments: ["key: TitleKey.self", "value: \"りんご\""],
            closing: ["}", ".onPreferenceChange(TitleKey.self) { title = $0 }"] + PreferenceCode.titleKey),
        build: { v in
            AnyView(TransformPreferenceDemo(choice: v.pick("transformPreference", from: [0, 1])))
        }
    )
}

private struct TransformPreferenceDemo: View {
    /// nil なら transformPreference をかけない
    let choice: Int?
    @State private var title = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("届いた題名: \(title)")
            child
        }
        .onPreferenceChange(DemoTitleKey.self) { title = $0 }
    }

    @ViewBuilder
    private var child: some View {
        let text = Text("子")
            .padding(8)
            .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
            .preference(key: DemoTitleKey.self, value: "りんご")
        switch choice {
        case 0?: text.transformPreference(DemoTitleKey.self) { $0 += "とぶどう" }
        case 1?: text.transformPreference(DemoTitleKey.self) { $0 = "もも" }
        default: text
        }
    }
}
