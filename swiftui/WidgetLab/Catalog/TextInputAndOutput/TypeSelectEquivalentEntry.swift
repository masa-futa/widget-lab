import SwiftUI

nonisolated extension CatalogEntry {
    static let typeSelectEquivalent = CatalogEntry(
        id: "typeSelectEquivalent",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "一覧で、キーボードで名前の頭を打って行を選ぶ（type select）ときに、行と照らす文字を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/typeselectequivalent(_:)")!,
        noteReason: "Mac で、キーボードから一覧の行を選ぶときに効く。iPhone の画面では試せない",
        properties: [
            .modifier(
                "typeSelectEquivalent", .choice([Choice("Text(fruit)"), Choice("\"\"")], initial: 0), on: true,
                summary: "照らす文字（OFF なら行の中の Text から決まる。空の文字なら、この行は打って選べない）")
        ],
        code: CodeTemplate(
            prefix: ["List(fruits, id: \\.self) { fruit in"], call: "Label",
            fixedArguments: ["fruit", "systemImage: \"leaf\""], closing: ["}"])
    )
}
