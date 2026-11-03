import SwiftUI

nonisolated extension CatalogEntry {
    static let onAppear = CatalogEntry(
        id: "onAppear",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "View が画面に現れる前に、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onappear(perform:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onAppear", label: "perform", .fixed(code: "{ print(\"子が現れた\") }"), on: true,
                summary: "現れるときの処理。トグルで子を出すたびに記録に出る")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    Toggle(\"子を出す\", isOn: $shows)", "    if shows {"], indent: 8, call: "Text",
            fixedArguments: ["\"子\""], closing: ["    }", "}"]),
        build: { v in
            AnyView(OnAppearDemo(watches: v["onAppear"] != nil))
        }
    )
}

private struct OnAppearDemo: View {
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
                        view.onAppear { recorder?.log("子が現れた") }
                    }
            }
        }
    }
}
