import SwiftUI

nonisolated extension CatalogEntry {
    static let geometryReader = CatalogEntry(
        id: "GeometryReader",
        kind: .view,
        topic: .drawingAndGraphics,
        summary: "置かれた枠いっぱいに広がり、その大きさと場所（GeometryProxy）を中身に渡す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/geometryreader")!,
        stage: .card,
        properties: [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 80...280, step: 20, initial: 200), on: true,
                summary: "枠の幅"),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 40...200, step: 20, initial: 100),
                on: true,
                summary: "枠の高さ"),
        ],
        code: CodeTemplate(
            call: "GeometryReader",
            trailing: " { proxy in\n    Circle()\n        .fill(.yellow)\n"
                + "        .frame(width: min(proxy.size.width, proxy.size.height))\n"
                + "    Text(\"\\(Int(proxy.size.width)) × \\(Int(proxy.size.height))\")\n}"),
        build: { v in
            AnyView(
                GeometryReader { proxy in
                    Circle()
                        .fill(.yellow)
                        .frame(width: min(proxy.size.width, proxy.size.height))
                    Text("\(Int(proxy.size.width)) × \(Int(proxy.size.height))")
                }
                .frame(
                    width: v.number("frame.width").map { CGFloat($0) },
                    height: v.number("frame.height").map { CGFloat($0) }
                )
                .border(.secondary)
            )
        }
    )
}
