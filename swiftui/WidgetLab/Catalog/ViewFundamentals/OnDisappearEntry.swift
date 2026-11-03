import SwiftUI

nonisolated extension CatalogEntry {
    static let onDisappear = CatalogEntry(
        id: "onDisappear",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View が画面から消えたあとに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/ondisappear(perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onDisappear", label: "perform", .fixed(code: "{ print(\"子が消えた\") }"), on: true,
                summary: "消えたときの処理。トグルで子を消すたびに記録に出る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Toggle(\"子を出す\", isOn: $shows)", "    if shows {"], indent: 8, call: "Text",
            fixedArguments: ["\"子\""], closing: ["    }", "}"]),
        build: { v in
            AnyView(OnDisappearDemo(watches: v["onDisappear"] != nil))
        }
    )
}

private struct OnDisappearDemo: View {
    let watches: Bool
    @State private var shows = true
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 12) {
            Toggle("子を出す", isOn: $shows)
                .fixedSize()
            if shows {
                Text("子")
                    .padding(8)
                    .background(.yellow)
                    .apply(watches ? () : nil) { view, _ in
                        view.onDisappear { recorder?.log("子が消えた") }
                    }
            }
        }
    }
}
