import SwiftUI

nonisolated extension CatalogEntry {
    static let privacySensitive = CatalogEntry(
        id: "privacySensitive",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "人に見せたくない情報の View に印を付ける modifier。redacted(reason: .privacy) のとき（ロック画面のウィジェットなど）に伏せられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/privacysensitive(_:)")!,
        stage: .card,
        properties: [
            .modifier("privacySensitive", .toggle(initial: true), on: true, summary: "true で印を付ける。省くと true")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"口座番号\")"], call: "Text", fixedArguments: ["\"1234-5678\""],
            closing: ["}", ".redacted(reason: .privacy)"]),
        build: { v in
            AnyView(
                VStack {
                    Text("口座番号")
                    Text("1234-5678")
                        .apply(v.flag("privacySensitive")) { $0.privacySensitive($1) }
                }
                .redacted(reason: .privacy)
            )
        }
    )
}
