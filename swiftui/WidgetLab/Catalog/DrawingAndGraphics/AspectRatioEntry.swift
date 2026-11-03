import SwiftUI

nonisolated extension CatalogEntry {
    static let aspectRatio = CatalogEntry(
        id: "aspectRatio",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の縦横比を決めて、置かれた枠に収める（または埋める）modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/aspectratio(_:contentmode:)")!,
        stage: .card,
        properties: [
            .argument(
                "aspectRatio", unlabeled: true, .slider(range: 0.5...3, step: 0.25, initial: 2), on: true,
                summary: "幅 ÷ 高さ（OFF なら View の元の比）"),
            .argument(
                "contentMode", .choice([Choice(".fit"), Choice(".fill")], initial: 0), required: true,
                summary: "枠に収めるか（.fit）、枠を埋めるか（.fill）"),
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"car.fill\")", "    .resizable()"], call: ".aspectRatio",
            suffix: [".frame(width: 200, height: 80)"]),
        build: { v in
            AnyView(
                Image(systemName: "car.fill")
                    .resizable()
                    .aspectRatio(
                        v.number("aspectRatio").map { CGFloat($0) },
                        contentMode: v.pick("contentMode", from: [ContentMode.fit, .fill]) ?? .fit
                    )
                    .frame(width: 200, height: 80)
                    .border(.secondary)
            )
        }
    )
}
