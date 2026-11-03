import SwiftUI

nonisolated extension CatalogEntry {
    static let mask = CatalogEntry(
        id: "mask",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "別の View の不透明なところだけを残して、View を描く modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/mask(alignment:_:)")!,
        stage: .card,
        properties: [
            .argument(
                "alignment", .choice([Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 0),
                on: true,
                summary: "マスクの View の揃え方（OFF なら .center）")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)",
                "    .frame(width: 240, height: 80)",
            ],
            call: ".mask",
            trailing: " {\n        Text(\"MASK\")\n            .font(.system(size: 56, weight: .black))\n    }"),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 240, height: 80)
                    .mask(alignment: v.pick("alignment", from: [Alignment.leading, .center, .trailing]) ?? .center) {
                        Text("MASK")
                            .font(.system(size: 56, weight: .black))
                    }
                    .border(.secondary)
            )
        }
    )
}
