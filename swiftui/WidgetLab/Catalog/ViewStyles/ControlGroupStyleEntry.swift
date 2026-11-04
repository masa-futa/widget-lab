import SwiftUI

nonisolated extension CatalogEntry {
    static let controlGroupStyle = CatalogEntry(
        id: "controlGroupStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "この View の中の ControlGroup の並べ方と見た目を、まとめて決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/controlgroupstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "controlGroupStyle",
                .choice(
                    [
                        Choice(".automatic"), Choice(".navigation"), Choice(".palette"), Choice(".menu"),
                        Choice(".compactMenu"),
                    ],
                    initial: 1),
                on: true, summary: "ControlGroup のスタイル。.menu・.compactMenu は名前のボタンから開く")
        ],
        code: CodeTemplate(
            call: "ControlGroup",
            trailing: " {\n    Button(\"戻る\", systemImage: \"chevron.left\") { }\n"
                + "    Button(\"進む\", systemImage: \"chevron.right\") { }\n} label: {\n"
                + "    Label(\"移動\", systemImage: \"arrow.left.arrow.right\")\n}"),
        build: { v in
            AnyView(
                ControlGroup {
                    Button("戻る", systemImage: "chevron.left") {}
                    Button("進む", systemImage: "chevron.right") {}
                } label: {
                    Label("移動", systemImage: "arrow.left.arrow.right")
                }
                .apply(v.pick("controlGroupStyle", from: ControlGroupStyleDemo.Style.allCases)) {
                    ControlGroupStyleDemo.styled($0, $1)
                }
                .frame(width: 240)
            )
        }
    )
}

private enum ControlGroupStyleDemo {
    enum Style: CaseIterable {
        case automatic, navigation, palette, menu, compactMenu
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.controlGroupStyle(.automatic)
        case .navigation: view.controlGroupStyle(.navigation)
        case .palette: view.controlGroupStyle(.palette)
        case .menu: view.controlGroupStyle(.menu)
        case .compactMenu: view.controlGroupStyle(.compactMenu)
        }
    }
}
