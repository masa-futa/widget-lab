import SwiftUI

nonisolated extension CatalogEntry {
    static let disclosureGroup = CatalogEntry(
        id: "DisclosureGroup",
        kind: .view,
        topic: .lists,
        summary: "開け閉めの印で、中身を見せたり隠したりする View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/disclosuregroup")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "詳しい設定"), required: true, summary: "見出し"),
            .argument("isExpanded", .fixed(code: "$isExpanded"), on: true, summary: "開いているかを外から持つ（最初は開いている）"),
            .modifier("tint", .color(initial: 1), summary: "強調の色（中の Toggle などにかかる）"),
        ],
        code: CodeTemplate(
            prefix: ["List {"], call: "DisclosureGroup",
            trailing: " {\n        Toggle(\"通知\", isOn: $notifies)\n        Text(\"音量: 中\")\n    }", closing: ["}"]),
        build: { v in
            AnyView(
                DisclosureGroupDemo(
                    title: v.text("title") ?? "", ownsState: v["isExpanded"] != nil, tint: v.color("tint"))
            )
        }
    )
}

private struct DisclosureGroupDemo: View {
    let title: String
    let ownsState: Bool
    let tint: Color?
    @State private var isExpanded = true
    @State private var notifies = true

    var body: some View {
        List {
            group
                .apply(tint) { $0.tint($1) }
        }
    }

    @ViewBuilder
    private var group: some View {
        if ownsState {
            DisclosureGroup(title, isExpanded: $isExpanded) { content }
        } else {
            DisclosureGroup(title) { content }
        }
    }

    @ViewBuilder
    private var content: some View {
        Toggle("通知", isOn: $notifies)
        Text("音量: 中")
    }
}
