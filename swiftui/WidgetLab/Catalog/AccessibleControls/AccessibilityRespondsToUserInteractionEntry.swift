import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRespondsToUserInteraction = CatalogEntry(
        id: "accessibilityRespondsToUserInteraction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "要素が押せるものかを、支援技術に伝える modifier。スイッチコントロール・音声コントロール・フルキーボードアクセスが、押せる要素として選ぶ。",
        docURL: URL(
            string:
                "https://developer.apple.com/documentation/swiftui/view/accessibilityrespondstouserinteraction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRespondsToUserInteraction", .toggle(initial: true), on: true,
                summary: "true なら押せるものとして伝える。false なら、押せる部品でも選ばれない")
        ],
        code: CodeTemplate(
            call: "Text", fixedArguments: ["\"お知らせ 3 件\""], suffix: [".onTapGesture { showNotices() }"]),
        build: { v in
            AnyView(RespondsToUserInteractionDemo(responds: v.flag("accessibilityRespondsToUserInteraction")))
        }
    )
}

private struct RespondsToUserInteractionDemo: View {
    /// nil なら modifier をかけない
    let responds: Bool?
    @State private var taps = 0

    var body: some View {
        A11yDemo(title: "音声コントロール・スイッチコントロール", lines: [lines]) {
            VStack(spacing: 8) {
                Text("お知らせ 3 件")
                    .font(.title3)
                    .padding(8)
                    .background(Color(.systemBackground), in: .rect(cornerRadius: 8))
                    .apply(responds) { view, responds in
                        view.accessibilityRespondsToUserInteraction(responds)
                    }
                    .onTapGesture { taps += 1 }
                Text("押した回数: \(taps)")
                    .font(.caption)
            }
        }
    }

    private var lines: String {
        responds == true ? "押せる要素として選べる（番号や名前が付く）" : "文字なので、押せる要素として選ばれない"
    }
}
