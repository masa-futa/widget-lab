import SwiftUI

nonisolated extension CatalogEntry {
    static let progressViewStyle = CatalogEntry(
        id: "progressViewStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の ProgressView の見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/progressviewstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "progressViewStyle",
                .choice([Choice(".automatic"), Choice(".linear"), Choice(".circular")], initial: 1),
                on: true, summary: "ProgressView の見た目のスタイル。iPhone の .circular は、値を渡しても回る印になる"),
            .modifier("tint", .color(initial: 5), summary: "棒・印の色"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    ProgressView(value: 0.4)\n    ProgressView()\n}"),
        build: { v in
            AnyView(
                VStack {
                    ProgressView(value: 0.4)
                    ProgressView()
                }
                .apply(v.pick("progressViewStyle", from: ProgressViewStyleDemo.Style.allCases)) {
                    ProgressViewStyleDemo.styled($0, $1)
                }
                .apply(v.color("tint")) { $0.tint($1) }
                .frame(width: 240)
            )
        }
    )
}

private enum ProgressViewStyleDemo {
    enum Style: CaseIterable {
        case automatic, linear, circular
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.progressViewStyle(.automatic)
        case .linear: view.progressViewStyle(.linear)
        case .circular: view.progressViewStyle(.circular)
        }
    }
}
