import SwiftUI

nonisolated extension CatalogEntry {
    static let presentationSizing = CatalogEntry(
        id: "presentationSizing",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "シートの大きさの決め方（中身に合わせる・決まった大きさなど）を決める modifier。シートの中身にかける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/presentationsizing(_:)")!,
        noteReason: "iPhone ではシートがいつも幅いっぱいに出るので、大きさは変わらない。iPad と Mac で、シートの大きさが変わる",
        properties: [
            .modifier(
                "presentationSizing",
                .choice([Choice(".automatic"), Choice(".form"), Choice(".page"), Choice(".fitted")], initial: 3),
                on: true, summary: "大きさの決め方。.fitted は中身の大きさに合わせる")
        ],
        code: .inSheet()
    )
}
