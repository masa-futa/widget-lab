import SwiftUI

nonisolated extension CatalogEntry {
    static let imageScale = CatalogEntry(
        id: "imageScale",
        kind: .modifier,
        topic: .images,
        summary: "この View の中の記号の大きさを、まわりの文字に対して小・中・大から選ぶ modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/imagescale(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "imageScale", .choice([Choice(".small"), Choice(".medium"), Choice(".large")], initial: 2), on: true,
                summary: "文字に対する記号の大きさ（OFF なら .medium）"),
            .modifier(
                "font", .choice([Choice(".body"), Choice(".title"), Choice(".largeTitle")], initial: 1), on: true,
                summary: "文字の大きさ。記号もこれに合わせる"),
        ],
        code: CodeTemplate(
            call: "HStack", trailing: " {\n    Image(systemName: \"star.fill\")\n    Text(\"お気に入り\")\n}"),
        build: { v in
            AnyView(
                HStack {
                    Image(systemName: "star.fill")
                    Text("お気に入り")
                }
                .apply(v.pick("imageScale", from: [Image.Scale.small, .medium, .large])) { $0.imageScale($1) }
                .apply(v.pick("font", from: [Font.body, .title, .largeTitle])) { $0.font($1) }
            )
        }
    )
}
