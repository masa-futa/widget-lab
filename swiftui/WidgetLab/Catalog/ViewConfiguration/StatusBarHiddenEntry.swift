import SwiftUI

nonisolated extension CatalogEntry {
    static let statusBarHidden = CatalogEntry(
        id: "statusBarHidden",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "画面のいちばん上のステータスバー（時刻や電池の表示）を隠すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/statusbarhidden(_:)")!,
        stage: .full,
        properties: [
            .modifier("statusBarHidden", .toggle(initial: true), on: true, summary: "true でステータスバーを隠す。省くと true")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"画面のいちばん上の時刻を見る\""]),
        build: { v in
            AnyView(
                Text("画面のいちばん上の時刻を見る")
                    .apply(v.flag("statusBarHidden")) { $0.statusBarHidden($1) }
            )
        }
    )
}
