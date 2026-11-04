import SwiftUI

nonisolated extension CatalogEntry {
    static let environment = CatalogEntry(
        id: "environment",
        kind: .modifier,
        topic: .environmentValues,
        summary: "環境の値（key path で選ぶ）を、かけた View とその下の View で書き換える modifier。Observable の物を渡す形もある。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/environment(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "environment",
                .choice(
                    [
                        Choice("文字を大きく", code: "\\.dynamicTypeSize, .xxxLarge"),
                        Choice("右から左へ", code: "\\.layoutDirection, .rightToLeft"),
                        Choice("使えなくする", code: "\\.isEnabled, false"),
                    ],
                    initial: 0),
                on: true, summary: "書き換える値の key path と、その値")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing:
                " {\n    Image(systemName: \"bell\")\n    Text(\"お知らせ\")\n    Toggle(\"受け取る\", isOn: $isOn).labelsHidden()\n}"
        ),
        build: { v in
            AnyView(EnvironmentModifierDemo(choice: v.pick("environment", from: [0, 1, 2])))
        }
    )
}

private struct EnvironmentModifierDemo: View {
    /// nil なら environment をかけない
    let choice: Int?
    @State private var isOn = true

    var body: some View {
        let row = HStack {
            Image(systemName: "bell")
            Text("お知らせ")
            Toggle("受け取る", isOn: $isOn).labelsHidden()
        }
        switch choice {
        case 0?: row.environment(\.dynamicTypeSize, .xxxLarge)
        case 1?: row.environment(\.layoutDirection, .rightToLeft)
        case 2?: row.environment(\.isEnabled, false)
        default: row
        }
    }
}
