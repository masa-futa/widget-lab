import SwiftUI

nonisolated extension CatalogEntry {
    static let environmentObject = CatalogEntry(
        id: "environmentObject",
        kind: .modifier,
        topic: .modelData,
        summary: "ObservableObject を、かけた View の下の View すべてに渡す modifier。受け取る側は @EnvironmentObject で読む。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/environmentobject(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "environmentObject",
                .choice(
                    [Choice("夜", code: "Theme(\"夜\")"), Choice("夕方", code: "Theme(\"夕方\")")], initial: 0),
                on: true, summary: "下の View に渡す物。外側で渡した「昼」より近いので、2 行目だけこちらが届く")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    ThemeLabel()"], call: "ThemeLabel",
            closing: [
                "}",
                ".environmentObject(Theme(\"昼\"))",
                "",
                "struct ThemeLabel: View {",
                "    @EnvironmentObject var theme: Theme",
                "    var body: some View { Text(\"テーマ: \\(theme.name)\") }",
                "}",
            ]),
        build: { v in
            AnyView(EnvironmentObjectModifierDemo(innerName: v.pick("environmentObject", from: ["夜", "夕方"])))
        }
    )
}

private struct EnvironmentObjectModifierDemo: View {
    /// nil なら 2 行目に environmentObject をかけない
    let innerName: String?
    @StateObject private var outer = DemoTheme("昼")

    var body: some View {
        VStack(spacing: 8) {
            ThemeLabel()
            ThemeLabel()
                .apply(innerName) { $0.environmentObject(DemoTheme($1)) }
        }
        .environmentObject(outer)
    }
}

private struct ThemeLabel: View {
    @EnvironmentObject var theme: DemoTheme

    var body: some View {
        Text("テーマ: \(theme.name)")
            .padding(8)
            .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
    }
}
