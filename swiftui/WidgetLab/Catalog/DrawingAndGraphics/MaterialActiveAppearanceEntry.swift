import SwiftUI

nonisolated extension CatalogEntry {
    static let materialActiveAppearance = CatalogEntry(
        id: "materialActiveAppearance",
        kind: .modifier,
        topic: .drawingAndGraphics,
        summary: "中の素材（material）を、窓が手前にあるとき（active）の見た目で描くかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/materialactiveappearance(_:)")!,
        noteReason: "macOS の窓が奥にあるときの、素材の見た目を決める。iOS では窓がいつも手前にあり、.inactive も使えないので、見た目は変わらない",
        properties: [
            .modifier(
                "materialActiveAppearance",
                .choice([Choice(".automatic"), Choice(".active"), Choice(".matchWindow")], initial: 1), on: true,
                summary: "素材の見た目（いつも手前・窓に合わせる）")
        ],
        code: CodeTemplate(
            prefix: ["Text(\"見本\")", "    .padding()"], call: ".background", fixedArguments: [".regularMaterial"])
    )
}
