import SwiftUI

nonisolated extension CatalogEntry {
    static let containerValue = CatalogEntry(
        id: "containerValue",
        kind: .modifier,
        topic: .viewGroupings,
        summary: "子の View に値を付け、入れ物が ForEach(subviews:) で読めるようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/containervalue(_:_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "containerValue", id: "containerValue.keyPath", .fixed(code: "\\.markColor"), required: true,
                summary: "値の種類（ContainerValues に @Entry で足したもの）"),
            .modifier(
                "containerValue", id: "containerValue.value", .color(initial: 0), on: true,
                summary: "付ける値。MarkedList は、この色の印を行の頭に付ける"),
        ],
        code: CodeTemplate(
            prefix: [
                "// markColor: ContainerValues に @Entry で足した Color?、MarkedList: 子ごとに markColor の印を付ける入れ物",
                "MarkedList {", "    Text(\"A\")",
            ],
            call: "Text", fixedArguments: ["\"B\""], closing: ["    Text(\"C\")", "}"]),
        build: { v in
            AnyView(
                MarkedList {
                    Text("A")
                    Text("B")
                        .apply(v.color("containerValue.value")) { $0.containerValue(\.markColor, $1) }
                    Text("C")
                }
            )
        }
    )
}

extension ContainerValues {
    /// 行の頭に付ける印の色
    @Entry var markColor: Color? = nil
}

/// 子を縦に並べ、markColor のある子の頭に印を付ける入れ物
private struct MarkedList<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(subviews: content) { subview in
                HStack {
                    Circle()
                        .fill(subview.containerValues.markColor ?? .clear)
                        .frame(width: 12, height: 12)
                    subview
                }
            }
        }
    }
}
