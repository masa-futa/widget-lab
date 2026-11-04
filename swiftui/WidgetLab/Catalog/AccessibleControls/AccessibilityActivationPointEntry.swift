import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityActivationPoint = CatalogEntry(
        id: "accessibilityActivationPoint",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術が要素を押すときに触れる場所を決める modifier。VoiceOver の 2 回タップは、ふつう要素の真ん中を押す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityactivationpoint(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityActivationPoint",
                .choice(
                    [Choice("スイッチの上", code: "UnitPoint(x: 0.85, y: 0.5)"), Choice(".leading")], initial: 0),
                on: true,
                summary: "押す場所（UnitPoint か CGPoint）。赤い点の場所を押す")
        ],
        code: CodeTemplate(
            call: "HStack",
            trailing: " {\n    Text(\"Wi-Fi\")\n    Spacer()\n    Toggle(\"\", isOn: $isOn).labelsHidden()\n}",
            suffix: [".accessibilityElement(children: .combine)"]),
        build: { v in
            AnyView(
                ActivationPointDemo(
                    point: v.pick("accessibilityActivationPoint", from: [UnitPoint(x: 0.85, y: 0.5), .leading])))
        }
    )
}

private struct ActivationPointDemo: View {
    /// nil なら modifier をかけない
    let point: UnitPoint?
    @State private var isOn = true

    var body: some View {
        A11yDemo(
            title: "VoiceOver が 2 回タップで押す場所",
            lines: [A11yText.element("Wi-Fi", value: isOn ? "1" : "0", traits: [".isToggle"]), lines]
        ) {
            HStack {
                Text("Wi-Fi")
                Spacer()
                Toggle("", isOn: $isOn).labelsHidden()
            }
            .padding(.horizontal, 12)
            .frame(width: 260, height: 52)
            .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
            .overlay { A11yPointMarker(point: point ?? .center) }
            .apply(point) { view, point in
                view.accessibilityActivationPoint(point)
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var lines: String {
        point == nil ? "赤い点（既定の真ん中。何もない所を押す）" : "赤い点"
    }
}
