import SwiftUI

nonisolated extension CatalogEntry {
    static let environmentWrapper = CatalogEntry(
        id: "Environment",
        kind: .propertyWrapper,
        topic: .environmentValues,
        summary: "View の環境（EnvironmentValues）から値を読む。親が値を変えると、読んでいる View が描き直される。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/environment")!,
        stage: .card,
        properties: [
            .wrapper("Environment", summary: "外すと、親が .disabled(true) をかけても、子は「使える」のまま変わらない。見本は使えなくした状態から始まる")
        ],
        code: CodeTemplate(
            call: "Environment",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "Button(\"親で使えなくする\") { disabled.toggle() }",
                    "StatusLabel()",
                    "    .disabled(disabled)",
                    "",
                    "// 子（StatusLabel）",
                    "@Environment(\\.isEnabled) private var isEnabled",
                    "var body: some View {",
                    "    Text(isEnabled ? \"使える\" : \"使えない\")",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "Button(\"親で使えなくする\") { disabled.toggle() }",
                    "StatusLabel()",
                    "    .disabled(disabled)",
                    "",
                    "// 子（StatusLabel）",
                    "private var isEnabled = true  // 環境を読まない",
                    "var body: some View {",
                    "    Text(isEnabled ? \"使える\" : \"使えない\")",
                    "}",
                ])),
        build: { v in
            AnyView(EnvironmentWrapperDemo(readsEnvironment: v["Environment"] != nil))
        }
    )
}

private struct EnvironmentWrapperDemo: View {
    let readsEnvironment: Bool
    /// 最初から使えなくしておく（付けない側との違いが、開いたときから見える）
    @State private var disabled = true

    var body: some View {
        VStack(spacing: 12) {
            Button(disabled ? "親で使えるようにする" : "親で使えなくする") { disabled.toggle() }
                .buttonStyle(.bordered)
            Group {
                if readsEnvironment {
                    ReadingLabel()
                } else {
                    FixedLabel()
                }
            }
            .disabled(disabled)
        }
    }

    struct ReadingLabel: View {
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            StatusText(isEnabled: isEnabled)
        }
    }

    struct FixedLabel: View {
        /// 環境を読まない
        private var isEnabled = true

        var body: some View {
            StatusText(isEnabled: isEnabled)
        }
    }

    struct StatusText: View {
        let isEnabled: Bool

        var body: some View {
            Label(isEnabled ? "使える" : "使えない", systemImage: isEnabled ? "checkmark.circle" : "xmark.circle")
                .padding(8)
                .background(isEnabled ? Color.green.opacity(0.3) : Color.gray.opacity(0.3), in: .rect(cornerRadius: 6))
        }
    }
}
