import SwiftUI

nonisolated extension CatalogEntry {
    static let clipped = CatalogEntry(
        id: "clipped",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View の枠からはみ出したところを切り取る modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/clipped(antialiased:)")!,
        stage: .card,
        properties: [
            .modifier("clipped", .fixed(code: ""), on: true, summary: "枠の外を切り取る")
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"car.fill\")", "    .resizable()", "    .scaledToFill()"], call: ".frame",
            fixedArguments: ["width: 200", "height: 60"]),
        build: { v in
            AnyView(
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 60)
                    .apply(v.flag("clipped")) { view, _ in view.clipped() }
                    .border(.red)
            )
        }
    )
}
