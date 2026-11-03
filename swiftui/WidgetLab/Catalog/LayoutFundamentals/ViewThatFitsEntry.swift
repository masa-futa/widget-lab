import SwiftUI

nonisolated extension CatalogEntry {
    static let viewThatFits = CatalogEntry(
        id: "ViewThatFits",
        kind: .view,
        topic: .layoutFundamentals,
        summary: "子の View を上から順に試し、入る大きさのものを 1 つだけ出す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/viewthatfits")!,
        stage: .card,
        properties: [
            .argument(
                "in",
                .choice([Choice(".horizontal"), Choice(".vertical"), Choice("[.horizontal, .vertical]")], initial: 0),
                summary: "入るかを確かめる向き（OFF なら縦横の両方）"),
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 40...280, step: 20, initial: 100), on: true,
                summary: "置く場所の幅（狭くすると、短い子に切り替わる）"),
        ],
        code: CodeTemplate(
            call: "ViewThatFits",
            trailing: " {\n    Label(\"お気に入りに追加\", systemImage: \"star\")\n    Text(\"お気に入り\")\n"
                + "    Image(systemName: \"star\")\n}",
            suffix: [".border(.secondary)"]),
        build: { v in
            let axes =
                v.pick("in", from: [Axis.Set.horizontal, .vertical, [.horizontal, .vertical]]) ?? [
                    .horizontal, .vertical,
                ]
            return AnyView(
                ViewThatFits(in: axes) {
                    Label("お気に入りに追加", systemImage: "star")
                    Text("お気に入り")
                    Image(systemName: "star")
                }
                .apply(v.number("frame.width")) { $0.frame(width: CGFloat($1)) }
                .border(.secondary)
            )
        }
    )
}
