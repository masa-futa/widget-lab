import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollInputBehavior = CatalogEntry(
        id: "scrollInputBehavior",
        kind: .modifier,
        topic: .scrollViews,
        summary: "決まった種類の入力で、ScrollView をスクロールできるかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollinputbehavior(_:for:)")!,
        noteReason: "入力の種類が、visionOS の見ることでのスクロール（.look）と、watchOS の指や手首の動き（.handGestureShortcut）だけで、iPhone では効かない",
        properties: [
            .modifier(
                "scrollInputBehavior", id: "scrollInputBehavior.behavior",
                .choice([Choice(".disabled"), Choice(".enabled"), Choice(".automatic")], initial: 0), on: true,
                summary: "その入力でスクロールできるか"),
            .modifier(
                "scrollInputBehavior", id: "scrollInputBehavior.kind", label: "for",
                .choice([Choice(".look"), Choice(".handGestureShortcut")], initial: 0), required: true,
                summary: "入力の種類"),
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}")
    )
}
