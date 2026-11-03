import SwiftUI

nonisolated extension CatalogEntry {
    static let dynamicTypeSize = CatalogEntry(
        id: "dynamicTypeSize",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "View の中の文字の大きさの設定（Dynamic Type）を、端末の設定にかかわらず決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/dynamictypesize(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "dynamicTypeSize",
                .choice(
                    [Choice(".xSmall"), Choice(".large"), Choice(".xxxLarge"), Choice(".accessibility2")], initial: 2),
                on: true, summary: "文字の大きさの設定（OFF なら端末の設定に従う。.large が標準）")
        ],
        code: CodeTemplate(
            call: "VStack", fixedArguments: ["alignment: .leading"],
            trailing: " {\n    Text(\"見出し\").font(.headline)\n    Text(\"本文の文字\").font(.body)\n}"),
        build: { v in
            AnyView(
                VStack(alignment: .leading) {
                    Text("見出し").font(.headline)
                    Text("本文の文字").font(.body)
                }
                .apply(
                    v.pick("dynamicTypeSize", from: [DynamicTypeSize.xSmall, .large, .xxxLarge, .accessibility2])
                ) { $0.dynamicTypeSize($1) }
            )
        }
    )
}
