import SwiftUI

nonisolated extension CatalogEntry {
    static let scaledToFill = CatalogEntry(
        id: "scaledToFill",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、縦横比を保ったまま、置かれた枠を埋める大きさにする modifier。枠からはみ出すところが出る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scaledtofill()")!,
        stage: .card,
        properties: [
            .modifier("resizable", .fixed(code: ""), on: true, summary: "画像を、置かれた大きさに伸び縮みさせる（OFF なら元の大きさ）"),
            .modifier("scaledToFill", .fixed(code: ""), on: true, summary: "枠を埋める大きさにする（はみ出す）"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"car.fill\""], suffix: [".frame(width: 200, height: 80)"]),
        build: { v in
            AnyView(
                ScaledToDemo.image(
                    resizable: v.flag("resizable") != nil, contentMode: v.flag("scaledToFill") != nil ? .fill : nil
                )
                .frame(width: 200, height: 80)
                .border(.secondary)
            )
        }
    )
}
