import SwiftUI

nonisolated extension CatalogEntry {
    static let pasteButton = CatalogEntry(
        id: "PasteButton",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "クリップボードの中身を読み、クロージャに渡すシステムのボタン。押したときだけ読むので、貼り付けの許可の確認が出ない。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/pastebutton")!,
        stage: .card,
        properties: [
            .modifier(
                "labelStyle",
                .choice([Choice(".titleAndIcon"), Choice(".iconOnly"), Choice(".titleOnly")], initial: 1),
                on: true, summary: "名前とアイコンの出し方"),
            .modifier(
                "buttonBorderShape",
                .choice([Choice(".capsule"), Choice(".roundedRectangle"), Choice(".circle")], initial: 0),
                summary: "ボタンの縁の形"),
            .modifier("tint", .color(initial: 3), summary: "ボタンの色"),
        ],
        code: CodeTemplate(
            call: "PasteButton", fixedArguments: ["payloadType: String.self"],
            trailing: " { strings in\n    pasted = strings.first ?? \"\"\n}"),
        build: { v in
            AnyView(
                PasteButtonDemo(
                    labelStyle: v.pick("labelStyle", from: PasteButtonDemo.LabelKind.allCases),
                    shape: v.pick("buttonBorderShape", from: [ButtonBorderShape.capsule, .roundedRectangle, .circle]),
                    tint: v.color("tint")))
        }
    )
}

private struct PasteButtonDemo: View {
    enum LabelKind: CaseIterable {
        case titleAndIcon, iconOnly, titleOnly
    }

    let labelStyle: LabelKind?
    let shape: ButtonBorderShape?
    let tint: Color?
    @State private var pasted = ""

    var body: some View {
        VStack(spacing: 12) {
            PasteButton(payloadType: String.self) { strings in
                pasted = strings.first ?? ""
            }
            .apply(labelStyle) { view, style in
                switch style {
                case .titleAndIcon: view.labelStyle(.titleAndIcon)
                case .iconOnly: view.labelStyle(.iconOnly)
                case .titleOnly: view.labelStyle(.titleOnly)
                }
            }
            .apply(shape) { $0.buttonBorderShape($1) }
            .apply(tint) { $0.tint($1) }
            Text(pasted.isEmpty ? "（まだ貼っていない）" : pasted)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
