import SwiftUI

nonisolated extension CatalogEntry {
    static let buttonSizing = CatalogEntry(
        id: "buttonSizing",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中のボタンを、中身に合わせた幅にするか、使える幅いっぱいに広げるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/buttonsizing(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "buttonSizing", .choice([Choice(".automatic"), Choice(".fitted"), Choice(".flexible")], initial: 2),
                on: true, summary: "ボタンの幅の決め方")
        ],
        code: CodeTemplate(
            call: "HStack", trailing: " {\n    Button(\"戻る\") { }\n    Button(\"次へ\") { }\n}",
            suffix: [".buttonStyle(.borderedProminent)", ".frame(width: 300)"]),
        build: { v in
            AnyView(
                HStack {
                    Button("戻る") {}
                    Button("次へ") {}
                }
                .apply(v.pick("buttonSizing", from: [ButtonSizing.automatic, .fitted, .flexible])) {
                    $0.buttonSizing($1)
                }
                .buttonStyle(.borderedProminent)
                .frame(width: 300)
                .border(.gray.opacity(0.4))
            )
        }
    )
}
