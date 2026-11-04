import SwiftUI

nonisolated extension CatalogEntry {
    static let onScrollPhaseChange = CatalogEntry(
        id: "onScrollPhaseChange",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView のスクロールの段階（止まっている・指で動かしている・惰性で動いているなど）が変わったときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onscrollphasechange(_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onScrollPhaseChange", .fixed(code: "{ old, new in print(\"\\(old) → \\(new)\") }"), on: true,
                summary: "変わったときの処理。スクロールするたびに記録に段階が出る")
        ],
        code: CodeTemplate(
            call: "ScrollView", trailing: " {\n    ForEach(1...30, id: \\.self) { Text(\"行 \\($0)\") }\n}"),
        build: { v in
            AnyView(OnScrollPhaseChangeDemo(watches: v["onScrollPhaseChange"] != nil))
        }
    )
}

private struct OnScrollPhaseChangeDemo: View {
    let watches: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        ScrollView {
            ForEach(1...30, id: \.self) { i in
                Text("行 \(i)")
                    .frame(maxWidth: .infinity, minHeight: 32)
            }
        }
        .apply(watches ? () : nil) { view, _ in
            view.onScrollPhaseChange { old, new in
                recorder?.log("\(Self.name(old)) → \(Self.name(new))")
            }
        }
    }

    private static func name(_ phase: ScrollPhase) -> String {
        switch phase {
        case .idle: "idle"
        case .tracking: "tracking"
        case .interacting: "interacting"
        case .decelerating: "decelerating"
        case .animating: "animating"
        @unknown default: "?"
        }
    }
}
