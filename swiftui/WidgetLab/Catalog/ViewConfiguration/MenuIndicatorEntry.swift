import SwiftUI

nonisolated extension CatalogEntry {
    static let menuIndicator = CatalogEntry(
        id: "menuIndicator",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "メニューを開くコントロールに、開けることを示す印（山形の矢印）を出すかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menuindicator(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuIndicator", .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2),
                on: true, summary: "印の出し方。.hidden で、選んだ値の横の山形の矢印が消える")
        ],
        code: CodeTemplate(
            call: "Picker", fixedArguments: ["\"果物\"", "selection: $fruit"],
            trailing: " {\n    Text(\"りんご\").tag(\"りんご\")\n    Text(\"みかん\").tag(\"みかん\")\n}"),
        build: { v in
            AnyView(
                MenuIndicatorDemo(visibility: v.pick("menuIndicator", from: [Visibility.automatic, .visible, .hidden])))
        }
    )
}

private struct MenuIndicatorDemo: View {
    let visibility: Visibility?
    @State private var fruit = "りんご"

    var body: some View {
        Picker("果物", selection: $fruit) {
            Text("りんご").tag("りんご")
            Text("みかん").tag("みかん")
        }
        .apply(visibility) { $0.menuIndicator($1) }
    }
}
