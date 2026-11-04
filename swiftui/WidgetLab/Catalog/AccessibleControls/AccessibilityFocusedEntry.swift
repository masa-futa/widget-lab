import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityFocused = CatalogEntry(
        id: "accessibilityFocused",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "VoiceOver などのカーソルがこの View にあるかを、@AccessibilityFocusState の値とつなぐ modifier。値を変えるとカーソルが移る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityfocused(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityFocused", .fixed(code: "$isTotalFocused"), on: true,
                summary: "つなぐ値（@AccessibilityFocusState）。VoiceOver を入れてボタンを押すと、カーソルが合計に移る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"合計へ移る\") { isTotalFocused = true }"], call: "Text",
            fixedArguments: ["\"合計: 1,200 円\""], closing: ["}"]),
        build: { v in
            AnyView(AccessibilityFocusDemo(connects: v["accessibilityFocused"] != nil))
        }
    )
}
