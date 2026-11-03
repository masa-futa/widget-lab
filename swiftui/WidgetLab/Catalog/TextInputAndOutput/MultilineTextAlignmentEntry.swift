import SwiftUI

nonisolated extension CatalogEntry {
    static let multilineTextAlignment = CatalogEntry(
        id: "multilineTextAlignment",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "複数行の文字の、行の揃え方（左寄せ・中央・右寄せ）を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/multilinetextalignment(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "multilineTextAlignment",
                .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 1),
                on: true, summary: "行の揃え方（OFF なら .leading）")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"短い行と、\\nそれより少し長い行と、\\n最後の行\""],
            suffix: [".frame(width: 220)"]),
        build: { v in
            AnyView(
                Text("短い行と、\nそれより少し長い行と、\n最後の行")
                    .apply(v.pick("multilineTextAlignment", from: [TextAlignment.leading, .center, .trailing])) {
                        $0.multilineTextAlignment($1)
                    }
                    .frame(width: 220)
                    .border(.secondary)
            )
        }
    )
}
