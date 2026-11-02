import SwiftUI

nonisolated extension CatalogEntry {
    static let layoutPriority = CatalogEntry(
        id: "layoutPriority",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "並びの中で、場所を先にもらう順を決める modifier。大きい値ほど先に場所をもらう。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/layoutpriority(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "layoutPriority", .slider(range: -1...2, step: 1, initial: 1), on: true,
                summary: "場所をもらう順（既定は 0）")
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"左の長い文字の見本\").lineLimit(1)"], call: "Text",
            fixedArguments: ["\"右の長い文字の見本\""], suffix: [".lineLimit(1)"], closing: ["}", ".frame(width: 240)"]),
        build: { v in
            AnyView(
                HStack {
                    Text("左の長い文字の見本").lineLimit(1).background(.yellow)
                    Text("右の長い文字の見本")
                        .apply(v.number("layoutPriority")) { $0.layoutPriority($1) }
                        .lineLimit(1)
                        .background(.orange)
                }
                .frame(width: 240)
            )
        }
    )
}
