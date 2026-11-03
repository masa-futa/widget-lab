import SwiftUI

nonisolated extension CatalogEntry {
    static let preferredColorScheme = CatalogEntry(
        id: "preferredColorScheme",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "画面（表示中の画面のまとまり）を、ライトとダークのどちらの見た目で出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "preferredColorScheme", .choice([Choice(".light"), Choice(".dark")], initial: 1), on: true,
                summary: "見た目。この画面ぜんたいが切り替わり、前の画面に戻ると元に戻る")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"画面ぜんたいが切り替わる\""]),
        build: { v in
            AnyView(
                Text("画面ぜんたいが切り替わる")
                    .apply(v.pick("preferredColorScheme", from: [ColorScheme.light, .dark])) {
                        $0.preferredColorScheme($1)
                    }
            )
        }
    )
}
