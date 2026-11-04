import SwiftUI

nonisolated extension CatalogEntry {
    static let onContinuousHover = CatalogEntry(
        id: "onContinuousHover",
        kind: .modifier,
        topic: .inputEvents,
        summary: "ポインタが View に入ったとき・中で動いたとき・出たときに、位置とともに処理を行う modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/oncontinuoushover(coordinatespace:perform:)"
        )!,
        noteReason: "iPhone にはポインタがないので、効き目は出ない。iPad のトラックパッドやマウス、Mac で効く",
        properties: [
            .modifier(
                "onContinuousHover", id: "onContinuousHover.coordinateSpace", label: "coordinateSpace",
                .choice([Choice(".local"), Choice(".global")], initial: 0), required: true, summary: "位置の基準"),
            .modifier(
                "onContinuousHover", label: "perform",
                .fixed(code: "{ phase in if case .active(let point) = phase { location = point } }"), on: true,
                summary: "ポインタが動くたびの処理（.active で位置、.ended で出たこと）"),
        ],
        code: CodeTemplate(call: "Rectangle", suffix: [".frame(width: 200, height: 120)"])
    )
}
