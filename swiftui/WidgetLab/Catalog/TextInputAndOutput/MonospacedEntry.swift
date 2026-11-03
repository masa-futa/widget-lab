import SwiftUI

nonisolated extension CatalogEntry {
    static let monospaced = CatalogEntry(
        id: "monospaced",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字を、どの文字も同じ幅の等幅のフォントにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/monospaced(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "monospaced", .toggle(initial: true), on: true, summary: "等幅にするか（false なら付けないのと同じ）")
        ],
        code: CodeTemplate(
            call: "VStack", fixedArguments: ["alignment: .leading"],
            trailing: " {\n    Text(\"iiiii 11111\")\n    Text(\"WWWWW 88888\")\n}", suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                VStack(alignment: .leading) {
                    Text("iiiii 11111")
                    Text("WWWWW 88888")
                }
                .apply(v.flag("monospaced")) { $0.monospaced($1) }
                .font(.title)
            )
        }
    )
}
