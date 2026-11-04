import SwiftUI

nonisolated extension CatalogEntry {
    static let preference = CatalogEntry(
        id: "preference",
        kind: .modifier,
        topic: .preferences,
        summary: "子の View から、親の View へ値を知らせる modifier。親は onPreferenceChange などで受け取る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/preference(key:value:)")!,
        stage: .card,
        properties: [
            .modifier(
                "preference", id: "preference.key", label: "key", .fixed(code: "TitleKey.self"), required: true,
                summary: "知らせる値の種類（PreferenceKey）"),
            .modifier(
                "preference", id: "preference.value", label: "value",
                .choice([Choice("\"りんご\""), Choice("\"ぶどう\"")], initial: 0), on: true,
                summary: "知らせる値。外すと、親には何も届かない"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Text(\"届いた題名: \\(title)\")"], call: "Text", fixedArguments: ["\"子\""],
            closing: ["}", ".onPreferenceChange(TitleKey.self) { title = $0 }"] + PreferenceCode.titleKey),
        build: { v in
            AnyView(PreferenceDemo(value: v.pick("preference.value", from: ["りんご", "ぶどう"])))
        }
    )
}

private struct PreferenceDemo: View {
    /// nil なら preference をかけない
    let value: String?
    @State private var title = ""

    var body: some View {
        VStack(spacing: 8) {
            Text("届いた題名: \(title.isEmpty ? "なし" : title)")
            Text("子")
                .padding(8)
                .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
                .apply(value) { $0.preference(key: DemoTitleKey.self, value: $1) }
        }
        .onPreferenceChange(DemoTitleKey.self) { title = $0 }
    }
}
