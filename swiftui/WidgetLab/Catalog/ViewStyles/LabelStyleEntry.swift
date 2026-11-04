import SwiftUI

nonisolated extension CatalogEntry {
    static let labelStyle = CatalogEntry(
        id: "labelStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の Label を、文字と絵のどちらで見せるかをまとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/labelstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "labelStyle",
                .choice(
                    [Choice(".automatic"), Choice(".titleAndIcon"), Choice(".titleOnly"), Choice(".iconOnly")],
                    initial: 3),
                on: true, summary: "Label の見せ方のスタイル"),
            .modifier("foregroundStyle", .color(initial: 4), summary: "文字と絵の色"),
        ],
        code: CodeTemplate(
            call: "VStack",
            fixedArguments: ["alignment: .leading"],
            trailing:
                " {\n    Label(\"お気に入り\", systemImage: \"star.fill\")\n    Label(\"履歴\", systemImage: \"clock\")\n}",
            suffix: [".font(.title2)"]),
        build: { v in
            AnyView(
                VStack(alignment: .leading) {
                    Label("お気に入り", systemImage: "star.fill")
                    Label("履歴", systemImage: "clock")
                }
                .apply(v.pick("labelStyle", from: LabelStyleDemo.Style.allCases)) { LabelStyleDemo.styled($0, $1) }
                .apply(v.color("foregroundStyle")) { $0.foregroundStyle($1) }
                .font(.title2)
            )
        }
    )
}

private enum LabelStyleDemo {
    enum Style: CaseIterable {
        case automatic, titleAndIcon, titleOnly, iconOnly
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.labelStyle(.automatic)
        case .titleAndIcon: view.labelStyle(.titleAndIcon)
        case .titleOnly: view.labelStyle(.titleOnly)
        case .iconOnly: view.labelStyle(.iconOnly)
        }
    }
}
