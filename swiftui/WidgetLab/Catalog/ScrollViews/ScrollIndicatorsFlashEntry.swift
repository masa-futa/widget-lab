import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollIndicatorsFlash = CatalogEntry(
        id: "scrollIndicatorsFlash",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView のスクロールバーを、現れたときや値が変わったときに一瞬だけ出す modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollindicatorsflash(trigger:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollIndicatorsFlash",
                .choice(
                    [Choice("count が変わるたび", code: "trigger: count"), Choice("現れたとき", code: "onAppear: true")],
                    initial: 0),
                on: true, summary: "バーを出すきっかけ（+1 を押す・見本が現れる）")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Button(\"+1\") { count += 1 }"], call: "ScrollView",
            trailing: " {\n        ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n    }", closing: ["}"]),
        build: { v in
            AnyView(ScrollIndicatorsFlashDemo(trigger: v.pick("scrollIndicatorsFlash", from: [true, false])))
        }
    )
}

private struct ScrollIndicatorsFlashDemo: View {
    /// true なら count が変わるたび、false なら現れたとき。nil なら付けない
    let trigger: Bool?
    @State private var count = 0

    var body: some View {
        VStack {
            Button("+1（\(count)）") { count += 1 }
                .buttonStyle(.bordered)
            ScrollView {
                ForEach(1...30, id: \.self) { i in
                    Text("行 \(i)")
                        .frame(maxWidth: .infinity, minHeight: 32)
                }
            }
            .apply(trigger) { view, byCount in
                if byCount {
                    view.scrollIndicatorsFlash(trigger: count)
                } else {
                    view.scrollIndicatorsFlash(onAppear: true)
                }
            }
        }
        .padding(.top, 8)
    }
}
