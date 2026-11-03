import SwiftUI

nonisolated extension CatalogEntry {
    static let clipShape = CatalogEntry(
        id: "clipShape",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "View を、決めた Shape の形に切り取る modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/clipshape(_:style:)")!,
        stage: .card,
        properties: [
            .modifier(
                "clipShape",
                .choice(
                    [Choice(".circle"), Choice(".rect(cornerRadius: 24)"), Choice(".capsule"), Choice(".ellipse")],
                    initial: 0),
                on: true, summary: "切り取る形")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 120"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 120)
                    .apply(
                        v.pick(
                            "clipShape",
                            from: [
                                AnyShape(.circle), AnyShape(.rect(cornerRadius: 24)), AnyShape(.capsule),
                                AnyShape(.ellipse),
                            ])
                    ) { $0.clipShape($1) }
            )
        }
    )
}
