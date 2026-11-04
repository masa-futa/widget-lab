import SwiftUI

nonisolated extension CatalogEntry {
    static let handlesExternalEvents = CatalogEntry(
        id: "handlesExternalEvents",
        kind: .modifier,
        topic: .systemEvents,
        summary: "外からの URL や NSUserActivity を、すでに開いているどのシーン（窓）で受けるかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/handlesexternalevents(preferring:allowing:)"
        )!,
        noteReason: "窓（シーン）を 2 つ以上開けるときに効く。iPhone はいつも窓が 1 つなので変わらない。iPad と Mac で、どの窓で受けるかを選ぶ",
        properties: [
            .modifier(
                "handlesExternalEvents", id: "handlesExternalEvents.preferring", label: "preferring",
                .fixed(code: "[\"memo\"]"), on: true, summary: "この窓で受けたいもの（URL や種類の文字列の一部）"),
            .modifier(
                "handlesExternalEvents", id: "handlesExternalEvents.allowing", label: "allowing",
                .fixed(code: "[\"*\"]"),
                required: true, summary: "この窓で受けてよいもの"),
        ],
        code: CodeTemplate(call: "MemoScreen")
    )
}
