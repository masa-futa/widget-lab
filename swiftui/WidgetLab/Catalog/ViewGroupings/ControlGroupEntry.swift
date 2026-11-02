import SwiftUI

nonisolated extension CatalogEntry {
    static let controlGroup = CatalogEntry(
        id: "ControlGroup",
        kind: .view,
        topic: .viewGroupings,
        summary: "関係のある操作部品（ボタンなど）を 1 つのまとまりとして出す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/controlgroup")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "文字の大きさ"), summary: "まとまりの名前（メニューのスタイルで出る）"),
            .modifier(
                "controlGroupStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".navigation"), Choice(".compactMenu"), Choice(".menu"),
                        Choice(".palette"),
                    ],
                    initial: 1),
                on: true, summary: "まとまりの見た目のスタイル"),
        ],
        code: CodeTemplate(
            call: "ControlGroup",
            trailing:
                " {\n    Button(\"小さく\", systemImage: \"minus\") { }\n    Button(\"大きく\", systemImage: \"plus\") { }\n}"
        ),
        build: { v in
            AnyView(
                ControlGroupDemo.group(title: v.text("title"))
                    .apply(v.pick("controlGroupStyle", from: ControlGroupDemo.Style.allCases)) {
                        ControlGroupDemo.styled($0, $1)
                    }
            )
        }
    )
}

private enum ControlGroupDemo {
    enum Style: CaseIterable {
        case automatic, navigation, compactMenu, menu, palette
    }

    @ViewBuilder
    static func group(title: String?) -> some View {
        if let title {
            ControlGroup(title) { buttons }
        } else {
            ControlGroup { buttons }
        }
    }

    @ViewBuilder
    private static var buttons: some View {
        Button("小さく", systemImage: "minus") {}
        Button("大きく", systemImage: "plus") {}
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.controlGroupStyle(.automatic)
        case .navigation: view.controlGroupStyle(.navigation)
        case .compactMenu: view.controlGroupStyle(.compactMenu)
        case .menu: view.controlGroupStyle(.menu)
        case .palette: view.controlGroupStyle(.palette)
        }
    }
}
