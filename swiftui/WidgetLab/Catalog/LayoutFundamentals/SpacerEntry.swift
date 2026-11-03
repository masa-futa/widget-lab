import SwiftUI

nonisolated extension CatalogEntry {
    static let spacer = CatalogEntry(
        id: "Spacer",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "並びの中で、空いた場所いっぱいに伸びる空白の View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/spacer")!,
        stage: .card,
        properties: [
            .argument(
                "minLength", .slider(range: 0...120, step: 10, initial: 80), on: true,
                summary: "縮めても残す長さ（OFF なら環境に合わせた既定の長さ）")
        ],
        code: CodeTemplate(
            prefix: ["HStack {", "    Text(\"左の文字が長いとき\")"], call: "Spacer",
            closing: ["    Text(\"右\")", "}", ".frame(width: 240)"]),
        build: { v in
            AnyView(
                HStack {
                    Text("左の文字が長いとき").background(.yellow)
                    Spacer(minLength: v.number("minLength").map { CGFloat($0) })
                    Text("右").background(.yellow)
                }
                .frame(width: 240)
                .border(.secondary)
            )
        }
    )
}
