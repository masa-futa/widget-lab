import SwiftUI

nonisolated extension CatalogEntry {
    static let ignoresSafeArea = CatalogEntry(
        id: "ignoresSafeArea",
        kind: .modifier,
        topic: .layoutAdjustments,
        summary: "View を、安全な領域（バーやキーボードを避けた範囲）の外まで広げる modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ignoressafearea(_:edges:)")!,
        stage: .card,
        properties: [
            .modifier(
                "ignoresSafeArea", id: "ignoresSafeArea.regions",
                .choice([Choice(".all"), Choice(".container"), Choice(".keyboard")], initial: 1), on: true,
                summary: "無視する安全な領域の種類（.container はバーなど、.keyboard はキーボード）"),
            .modifier(
                "ignoresSafeArea", id: "ignoresSafeArea.edges", label: "edges",
                .choice([Choice(".all"), Choice(".top"), Choice(".bottom")], initial: 1), on: true,
                summary: "無視する辺"),
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "Rectangle", suffix: [".foregroundStyle(.yellow)"],
            closing: ["}", ".safeAreaPadding(.vertical, 40)"]),
        build: { v in
            let regions = v.pick("ignoresSafeArea.regions", from: [SafeAreaRegions.all, .container, .keyboard])
            let edges = v.pick("ignoresSafeArea.edges", from: [Edge.Set.all, .top, .bottom])
            return AnyView(
                VStack {
                    Rectangle()
                        .apply(regions != nil || edges != nil ? () : nil) { view, _ in
                            view.ignoresSafeArea(regions ?? .all, edges: edges ?? .all)
                        }
                        .foregroundStyle(.yellow)
                }
                .safeAreaPadding(.vertical, 40)
                .border(.secondary)
            )
        }
    )
}
