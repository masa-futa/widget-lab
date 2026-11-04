import SwiftUI

nonisolated extension CatalogEntry {
    static let transformEnvironment = CatalogEntry(
        id: "transformEnvironment",
        kind: .modifier,
        topic: .environmentValues,
        summary: "親から届いた環境の値を、関数で書き換えてから下の View に渡す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/transformenvironment(_:transform:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transformEnvironment",
                .choice(
                    [
                        Choice("太字に", code: "\\.font, transform: { font in font = font?.bold() }"),
                        Choice("斜体に", code: "\\.font, transform: { font in font = font?.italic() }"),
                        Choice("大きい文字に", code: "\\.font, transform: { font in font = .largeTitle }"),
                    ],
                    initial: 0),
                on: true, summary: "書き換える値の key path と、書き換える関数。親の .font(.title2) を元に変える")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing: " {\n    Text(\"見出し\")\n    Text(\"本文\")\n}",
            suffix: [".font(.title2)"]),
        build: { v in
            AnyView(TransformEnvironmentDemo(choice: v.pick("transformEnvironment", from: [0, 1, 2])))
        }
    )
}

private struct TransformEnvironmentDemo: View {
    /// nil なら transformEnvironment をかけない
    let choice: Int?

    var body: some View {
        let stack = VStack {
            Text("見出し")
            Text("本文")
        }
        Group {
            switch choice {
            case 0?: stack.transformEnvironment(\.font) { font in font = font?.bold() }
            case 1?: stack.transformEnvironment(\.font) { font in font = font?.italic() }
            case 2?: stack.transformEnvironment(\.font) { font in font = .largeTitle }
            default: stack
            }
        }
        .font(.title2)
    }
}
