import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollViewReader = CatalogEntry(
        id: "ScrollViewReader",
        kind: .view,
        topic: .scrollViews,
        summary: "中の ScrollView を、id を付けた子の場所までコードでスクロールさせる窓口（proxy）を渡す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scrollviewreader")!,
        stage: .card,
        properties: [
            .argument(
                "anchor", .choice([Choice(".top"), Choice(".center"), Choice(".bottom")], initial: 1), on: true,
                summary: "scrollTo で、子を枠のどこに合わせるか（OFF なら見えるところまで）")
        ],
        code: CodeTemplate(
            prefix: ["ScrollViewReader { proxy in", "    Button(\"行 30 へ\") {", "        withAnimation {"], indent: 12,
            call: "proxy.scrollTo", fixedArguments: ["30"],
            closing: [
                "        }", "    }", "    ScrollView {", "        ForEach(1...50, id: \\.self) { i in",
                "            Text(\"行 \\(i)\").id(i)", "        }", "    }", "}",
            ]),
        build: { v in
            AnyView(ScrollViewReaderDemo(anchor: v.pick("anchor", from: [UnitPoint.top, .center, .bottom])))
        }
    )
}

private struct ScrollViewReaderDemo: View {
    let anchor: UnitPoint?

    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                HStack {
                    Button("行 30 へ") {
                        withAnimation { proxy.scrollTo(30, anchor: anchor) }
                    }
                    Button("行 1 へ") {
                        withAnimation { proxy.scrollTo(1, anchor: anchor) }
                    }
                }
                .buttonStyle(.bordered)
                ScrollView {
                    ForEach(1...50, id: \.self) { i in
                        Text("行 \(i)")
                            .frame(maxWidth: .infinity, minHeight: 32)
                            .background(i == 30 ? .yellow : .clear)
                            .id(i)
                    }
                }
            }
            .padding(.top, 8)
        }
    }
}
