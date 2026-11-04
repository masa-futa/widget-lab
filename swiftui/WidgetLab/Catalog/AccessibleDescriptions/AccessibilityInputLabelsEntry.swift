import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityInputLabels = CatalogEntry(
        id: "accessibilityInputLabels",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "音声コントロールなどで要素を呼ぶ名前を、ラベルとは別に足す modifier。長いラベルのボタンを、短い言葉で押せるようにする。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityinputlabels(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityInputLabels", .fixed(code: "[\"保存\", \"セーブ\"]"), on: true,
                summary: "呼ぶ名前の候補。前にあるものほど優先する")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"保存して閉じる\""], trailing: " { saveAndClose() }"),
        build: { v in
            AnyView(InputLabelsDemo(hasInputLabels: v["accessibilityInputLabels"] != nil))
        }
    )
}

private struct InputLabelsDemo: View {
    let hasInputLabels: Bool

    var body: some View {
        A11yDemo(title: "音声コントロールで押すときの言い方", lines: lines) {
            Button("保存して閉じる") {}
                .buttonStyle(.borderedProminent)
                .apply(hasInputLabels ? () : nil) { view, _ in
                    view.accessibilityInputLabels(["保存", "セーブ"])
                }
        }
    }

    private var lines: [String] {
        hasInputLabels
            ? ["「保存をタップ」", "「セーブをタップ」", "（VoiceOver はラベルの「保存して閉じる」を読む）"]
            : ["「保存して閉じるをタップ」（ラベルを全部言う）"]
    }
}
