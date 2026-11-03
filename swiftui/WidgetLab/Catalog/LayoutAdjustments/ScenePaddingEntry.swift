import SwiftUI

nonisolated extension CatalogEntry {
    static let scenePadding = CatalogEntry(
        id: "scenePadding",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "画面（シーン）の端に合わせた余白を足す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scenepadding(_:)")!,
        stage: .card,
        properties: [
            .argument(
                "edges", unlabeled: true,
                .choice([Choice(".all"), Choice(".horizontal"), Choice(".vertical"), Choice(".top")], initial: 1),
                on: true, summary: "余白を足す辺（OFF ならすべての辺）")
        ],
        code: CodeTemplate(prefix: ["Text(\"見本\")"], call: ".scenePadding", suffix: [".background(.yellow)"]),
        build: { v in
            AnyView(
                Text("見本")
                    .scenePadding(v.pick("edges", from: [Edge.Set.all, .horizontal, .vertical, .top]) ?? .all)
                    .background(.yellow)
            )
        }
    )
}
