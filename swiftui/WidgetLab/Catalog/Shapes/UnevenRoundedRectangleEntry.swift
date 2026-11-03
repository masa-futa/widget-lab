import SwiftUI

nonisolated extension CatalogEntry {
    static let unevenRoundedRectangle = CatalogEntry(
        id: "UnevenRoundedRectangle",
        kind: .view,
        topic: .shapes,
        summary: "4 つの角を、それぞれ別の半径で丸めた長方形の Shape。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/unevenroundedrectangle")!,
        stage: .card,
        properties: [
            .argument(
                "topLeadingRadius", .slider(range: 0...50, step: 5, initial: 40), on: true,
                summary: "左上の角の半径（OFF なら 0）"),
            .argument(
                "bottomLeadingRadius", .slider(range: 0...50, step: 5, initial: 10), summary: "左下の角の半径（OFF なら 0）"),
            .argument(
                "bottomTrailingRadius", .slider(range: 0...50, step: 5, initial: 40), on: true,
                summary: "右下の角の半径（OFF なら 0）"),
            .argument("topTrailingRadius", .slider(range: 0...50, step: 5, initial: 10), summary: "右上の角の半径（OFF なら 0）"),
            .argument(
                "style", .choice([Choice(".circular"), Choice(".continuous")], initial: 0),
                summary: "丸みの形（OFF なら .continuous）"),
        ],
        code: CodeTemplate(
            call: "UnevenRoundedRectangle", suffix: [".fill(.blue)", ".frame(width: 160, height: 100)"]),
        build: { v in
            AnyView(
                UnevenRoundedRectangle(
                    topLeadingRadius: CGFloat(v.number("topLeadingRadius") ?? 0),
                    bottomLeadingRadius: CGFloat(v.number("bottomLeadingRadius") ?? 0),
                    bottomTrailingRadius: CGFloat(v.number("bottomTrailingRadius") ?? 0),
                    topTrailingRadius: CGFloat(v.number("topTrailingRadius") ?? 0),
                    style: v.pick("style", from: [RoundedCornerStyle.circular, .continuous]) ?? .continuous
                )
                .fill(.blue)
                .frame(width: 160, height: 100)
            )
        }
    )
}
