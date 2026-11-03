import SwiftUI

nonisolated extension CatalogEntry {
    static let controlSize = CatalogEntry(
        id: "controlSize",
        kind: .modifier,
        topic: .controlsAndIndicators,
        summary: "中にあるコントロールの大きさを、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlsize(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "controlSize",
                .choice(
                    [Choice(".mini"), Choice(".small"), Choice(".regular"), Choice(".large"), Choice(".extraLarge")],
                    initial: 3),
                on: true, summary: "コントロールの大きさ")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Button(\"保存\") { }\n        .buttonStyle(.bordered)\n    ProgressView()\n}"),
        build: { v in
            AnyView(
                HStack {
                    Button("保存") {}
                        .buttonStyle(.bordered)
                    ProgressView()
                }
                .apply(v.pick("controlSize", from: [ControlSize.mini, .small, .regular, .large, .extraLarge])) {
                    $0.controlSize($1)
                }
            )
        }
    )
}
