import SwiftUI

nonisolated extension CatalogEntry {
    static let assistiveAccessNavigationIcon = CatalogEntry(
        id: "assistiveAccessNavigationIcon",
        kind: .modifier,
        topic: .accessibleAppearance,
        summary: "アシスティブアクセスのとき、画面の題名の横や戻るボタンに出す絵を決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/assistiveaccessnavigationicon(systemimage:)"
        )!,
        noteReason:
            "アシスティブアクセス（設定で入れる、ホーム画面ごと簡単な見た目に切り替える仕組み）のときだけ効く。アプリの中からは切り替えられない。アシスティブアクセスに対応したアプリで、画面の題名の横に絵を出すときに使う",
        properties: [
            .modifier(
                "assistiveAccessNavigationIcon",
                .choice(
                    [
                        Choice("SF Symbols", code: "systemImage: \"photo\""),
                        Choice("画像", code: "Image(\"PhotosIcon\")"),
                    ], initial: 0), on: true,
                summary: "出す絵。SF Symbols の名前か Image")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "Text", fixedArguments: ["\"写真の一覧\""],
            suffix: [".navigationTitle(\"写真\")"], closing: ["}"])
    )
}
