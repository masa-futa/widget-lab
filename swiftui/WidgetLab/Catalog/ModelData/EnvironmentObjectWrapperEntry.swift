import SwiftUI

nonisolated extension CatalogEntry {
    static let environmentObjectWrapper = CatalogEntry(
        id: "EnvironmentObject",
        kind: .propertyWrapper,
        topic: .modelData,
        summary: "親や先祖の View が .environmentObject で渡した ObservableObject を読む。間の View に引数を足さなくてよい。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/environmentobject")!,
        stage: .behavior,
        properties: [
            .wrapper(
                "EnvironmentObject",
                summary: "外すと、間の View（Middle）にも引数を足して、手で渡していくことになる。渡す物が見つからないと、@EnvironmentObject は止まる")
        ],
        code: CodeTemplate(
            call: "EnvironmentObject",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "@StateObject private var theme = Theme(\"昼\")",
                    "var body: some View {",
                    "    Button(\"夜にする\") { theme.name = \"夜\" }",
                    "    Middle()",
                    "        .environmentObject(theme)",
                    "}",
                    "",
                    "// 間（Middle）",
                    "var body: some View { ThemeLabel() }",
                    "",
                    "// 子（ThemeLabel）",
                    "@EnvironmentObject var theme: Theme",
                    "var body: some View { Text(\"テーマ: \\(theme.name)\") }",
                ],
                withoutWrapper: [
                    "// 親",
                    "@StateObject private var theme = Theme(\"昼\")",
                    "var body: some View {",
                    "    Button(\"夜にする\") { theme.name = \"夜\" }",
                    "    Middle(theme: theme)",
                    "}",
                    "",
                    "// 間（Middle）",
                    "let theme: Theme",
                    "var body: some View { ThemeLabel(theme: theme) }",
                    "",
                    "// 子（ThemeLabel）",
                    "@ObservedObject var theme: Theme",
                    "var body: some View { Text(\"テーマ: \\(theme.name)\") }",
                ])),
        build: { v in
            AnyView(EnvironmentObjectDemo.Parent(usesEnvironment: v["EnvironmentObject"] != nil))
        }
    )
}

private enum EnvironmentObjectDemo {
    struct Parent: View {
        let usesEnvironment: Bool
        @StateObject private var theme = DemoTheme("昼")
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "親")
            VStack(spacing: 8) {
                Button(theme.name == "昼" ? "夜にする" : "昼にする") {
                    theme.name = theme.name == "昼" ? "夜" : "昼"
                    recorder?.log("テーマを \(theme.name) にした")
                }
                .buttonStyle(.bordered)
                if usesEnvironment {
                    EnvironmentMiddle()
                        .environmentObject(theme)
                } else {
                    PassingMiddle(theme: theme)
                }
            }
        }
    }

    struct EnvironmentMiddle: View {
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "間")
            EnvironmentLabel()
        }
    }

    struct EnvironmentLabel: View {
        @EnvironmentObject var theme: DemoTheme
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            Text("テーマ: \(theme.name)")
        }
    }

    struct PassingMiddle: View {
        let theme: DemoTheme
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "間")
            PassedLabel(theme: theme)
        }
    }

    struct PassedLabel: View {
        @ObservedObject var theme: DemoTheme
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            let _ = reportBody(recorder, "子")
            Text("テーマ: \(theme.name)")
        }
    }
}
