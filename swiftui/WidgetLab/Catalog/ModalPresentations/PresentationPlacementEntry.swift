import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationPlacement = CatalogEntry(
        id: "presentationPlacement",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートを、出した画面の中のどこ（前の端・真ん中・後ろの端）に置くかを決める modifier。シートだけが従う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationplacement(_:)")!,
        noteReason: "iPhone ではシートがいつも幅いっぱいに出るので、置く場所は変わらない。iPad など幅の広い画面で、シートを端に寄せる",
        properties: [
            .modifier(
                "presentationPlacement",
                .choice(
                    [Choice(".automatic"), Choice(".leading"), Choice(".center"), Choice(".trailing")], initial: 1),
                on: true, summary: "シートを置く場所")
        ],
        code: CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"シートの中身\""], suffix: [".presentationDetents([.medium])"],
            closing: ["    }"])
    )
}
