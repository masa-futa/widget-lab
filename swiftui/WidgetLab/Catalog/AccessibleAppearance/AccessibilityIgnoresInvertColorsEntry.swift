import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityIgnoresInvertColors = CatalogEntry(
        id: "accessibilityIgnoresInvertColors",
        kind: .modifier,
        topic: .accessibleAppearance,
        summary: "設定のスマート反転で、この View の色を反転しないようにする modifier。写真や絵に付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityignoresinvertcolors(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityIgnoresInvertColors", .toggle(initial: true), on: true,
                summary: "true なら反転しない。設定 > アクセシビリティ > 画面表示とテキストサイズ > 反転（スマート）を入れて見る")
        ],
        code: CodeTemplate(
            prefix: ["HStack {"], call: "Image", fixedArguments: ["\"sunset\""], closing: ["    Text(\"夕焼け\")", "}"]),
        build: { v in
            AnyView(InvertColorsDemo(ignores: v.flag("accessibilityIgnoresInvertColors")))
        }
    )
}

private struct InvertColorsDemo: View {
    /// nil なら modifier をかけない
    let ignores: Bool?
    @Environment(\.accessibilityInvertColors) private var invertColors

    var body: some View {
        A11yDemo(title: "スマート反転のとき", lines: lines) {
            HStack(spacing: 12) {
                // 写真の代わりの絵
                LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom)
                    .overlay { Image(systemName: "sun.horizon.fill").font(.largeTitle).foregroundStyle(.yellow) }
                    .frame(width: 96, height: 72)
                    .clipShape(.rect(cornerRadius: 8))
                    .apply(ignores) { view, ignores in
                        view.accessibilityIgnoresInvertColors(ignores)
                    }
                Text("夕焼け")
                    .font(.title3)
            }
        }
    }

    private var lines: [String] {
        [
            ignores == true ? "写真は元の色のまま、まわりだけ反転する" : "写真も反転して、色が逆になる",
            "今のスマート反転: \(invertColors ? "入" : "切")",
        ]
    }
}
