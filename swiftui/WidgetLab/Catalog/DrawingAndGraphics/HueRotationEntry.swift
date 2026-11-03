import SwiftUI

nonisolated extension CatalogEntry {
    static let hueRotation = CatalogEntry(
        id: "hueRotation",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "色相を、決めた角度だけ回す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/huerotation(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "hueRotation",
                .choice([Choice(".degrees(60)"), Choice(".degrees(120)"), Choice(".degrees(180)")], initial: 1),
                on: true, summary: "色相を回す角度")
        ],
        code: CodeTemplate(
            prefix: [
                "LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)"
            ],
            call: ".frame", fixedArguments: ["width: 200", "height: 80"]),
        build: { v in
            AnyView(
                LinearGradient(colors: [.red, .yellow, .green, .blue], startPoint: .leading, endPoint: .trailing)
                    .frame(width: 200, height: 80)
                    .apply(v.pick("hueRotation", from: [Angle.degrees(60), .degrees(120), .degrees(180)])) {
                        $0.hueRotation($1)
                    }
            )
        }
    )
}
