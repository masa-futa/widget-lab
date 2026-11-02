import SwiftUI

nonisolated extension CatalogEntry {
    static let groupBox = CatalogEntry(
        id: "GroupBox",
        kind: .view,
        topic: .viewGroupings,
        summary: "見出しと中身を、背景の付いた箱にまとめる View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/groupbox")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "設定"), on: true, summary: "箱の見出し"),
            .modifier("backgroundStyle", .color(initial: 2), on: true, summary: "箱の背景"),
        ],
        code: CodeTemplate(call: "GroupBox", trailing: " {\n    Text(\"通知を受け取る\")\n}"),
        build: { v in
            AnyView(
                GroupBoxDemo.box(title: v.text("title"))
                    .apply(v.color("backgroundStyle")) { $0.backgroundStyle($1) }
                    .padding()
            )
        }
    )
}

private enum GroupBoxDemo {
    @ViewBuilder
    static func box(title: String?) -> some View {
        if let title {
            GroupBox(title) { Text("通知を受け取る") }
        } else {
            GroupBox { Text("通知を受け取る") }
        }
    }
}
