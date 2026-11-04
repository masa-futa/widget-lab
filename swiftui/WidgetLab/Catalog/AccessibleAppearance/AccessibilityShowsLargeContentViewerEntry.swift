import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityShowsLargeContentViewer = CatalogEntry(
        id: "accessibilityShowsLargeContentViewer",
        kind: .modifier,
        topic: .accessibleAppearance,
        summary: "文字を特大にしているとき、長押しで View を画面の真ん中に大きく出す modifier。大きくできないバーのボタンに付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityshowslargecontentviewer()")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityShowsLargeContentViewer",
                .choice(
                    [Choice("既定", code: ""), Choice("中身を渡す", code: "{ Label(\"ホーム\", systemImage: \"house\") }")],
                    initial: 0), on: true,
                summary: "大きく出す中身。既定はボタンのラベル。設定で文字をアクセシビリティのサイズにして、ボタンを長押しする")
        ],
        code: CodeTemplate(
            call: "Button", trailing: " {\n    goHome()\n} label: {\n    Image(systemName: \"house\")\n}"),
        build: { v in
            AnyView(LargeContentViewerDemo(content: v.pick("accessibilityShowsLargeContentViewer", from: [0, 1])))
        }
    )
}

private struct LargeContentViewerDemo: View {
    /// nil なら modifier をかけない。0 既定・1 中身を渡す
    let content: Int?
    @Environment(\.accessibilityLargeContentViewerEnabled) private var isEnabled

    var body: some View {
        A11yDemo(title: "長押しで大きく出るもの", lines: lines) {
            Button {
            } label: {
                Image(systemName: "house")
                    .font(.title2)
            }
            .buttonStyle(.bordered)
            .apply(content) { view, content in
                if content == 0 {
                    view.accessibilityShowsLargeContentViewer()
                } else {
                    view.accessibilityShowsLargeContentViewer {
                        Label("ホーム", systemImage: "house")
                    }
                }
            }
        }
    }

    private var lines: [String] {
        let shown =
            switch content {
            case 0: "家の絵"
            case 1: "家の絵と「ホーム」"
            default: "なし（長押ししても出ない）"
            }
        return [
            shown,
            "今は\(isEnabled ? "使える" : "使えない（文字がアクセシビリティのサイズでない）")",
        ]
    }
}
