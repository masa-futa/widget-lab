import SwiftUI

nonisolated extension CatalogEntry {
    static let colorPicker = CatalogEntry(
        id: "ColorPicker",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "システムの色の選び方の画面を開き、色を選ぶコントロール。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/colorpicker")!,
        stage: .card,
        properties: [
            .argument("supportsOpacity", .toggle(initial: false), on: true, summary: "透明度も選べるようにする。省くと true"),
            .modifier("labelsHidden", .fixed(code: ""), summary: "名前を隠し、色の丸だけにする"),
        ],
        code: CodeTemplate(call: "ColorPicker", fixedArguments: ["\"色\"", "selection: $color"]),
        build: { v in
            AnyView(ColorPickerDemo(supportsOpacity: v.flag("supportsOpacity"), hidesLabel: v["labelsHidden"] != nil))
        }
    )
}

private struct ColorPickerDemo: View {
    let supportsOpacity: Bool?
    let hidesLabel: Bool
    @State private var color = Color.orange

    var body: some View {
        HStack(spacing: 16) {
            ColorPicker("色", selection: $color, supportsOpacity: supportsOpacity ?? true)
                .apply(hidesLabel ? () : nil) { view, _ in view.labelsHidden() }
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 44, height: 44)
        }
        .frame(width: 240)
    }
}
