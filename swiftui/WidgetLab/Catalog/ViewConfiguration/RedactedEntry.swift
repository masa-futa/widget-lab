import SwiftUI

nonisolated extension CatalogEntry {
    static let redacted = CatalogEntry(
        id: "redacted",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にある View を伏せて見せる modifier。読み込み中の仮の表示などに使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/redacted(reason:)")!,
        stage: .card,
        properties: [
            .modifier(
                "redacted", label: "reason",
                .choice([Choice(".placeholder"), Choice(".invalidated")], initial: 0), on: true,
                summary: "伏せる理由。.placeholder は文字と画像を灰色の形に、.invalidated は中身を薄くする。.privacy は privacySensitive の収録で見る")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Image(systemName: \"person.crop.circle\")\n    Text(\"山田 花子\")\n    Text(\"1234-5678\")\n}"),
        build: { v in
            AnyView(
                VStack {
                    Image(systemName: "person.crop.circle")
                        .font(.largeTitle)
                    Text("山田 花子")
                    Text("1234-5678")
                }
                .apply(v.pick("redacted", from: [RedactionReasons.placeholder, .invalidated])) {
                    $0.redacted(reason: $1)
                }
            )
        }
    )
}
