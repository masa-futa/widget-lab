import SwiftUI

nonisolated extension CatalogEntry {
    static let monospacedDigit = CatalogEntry(
        id: "monospacedDigit",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の数字だけを同じ幅にする modifier。桁がそろい、数字が変わっても幅が揺れない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/monospaceddigit()")!,
        stage: .card,
        properties: [
            .modifier("monospacedDigit", .fixed(code: ""), on: true, summary: "数字を同じ幅にする")
        ],
        code: CodeTemplate(
            call: "VStack", fixedArguments: ["alignment: .trailing"],
            trailing: " {\n    Text(\"1,111.11\")\n    Text(\"8,888.88\")\n}", suffix: [".font(.title)"]),
        build: { v in
            AnyView(
                VStack(alignment: .trailing) {
                    Text("1,111.11")
                    Text("8,888.88")
                }
                .apply(v.flag("monospacedDigit")) { view, _ in view.monospacedDigit() }
                .font(.title)
            )
        }
    )
}
