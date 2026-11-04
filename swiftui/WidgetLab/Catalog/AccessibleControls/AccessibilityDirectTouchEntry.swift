import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityDirectTouch = CatalogEntry(
        id: "accessibilityDirectTouch",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "VoiceOver が入っていても、指で触れた操作をそのままアプリに渡す場所にする modifier。楽器の鍵盤などに付ける。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilitydirecttouch(_:options:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityDirectTouch", id: "accessibilityDirectTouch.isDirectTouchArea", label: nil,
                .toggle(initial: true), on: true,
                summary: "true なら、触れた操作をそのままアプリに渡す"),
            .modifier(
                "accessibilityDirectTouch", id: "accessibilityDirectTouch.options", label: "options",
                .choice([Choice(".silentOnTouch"), Choice(".requiresActivation")], initial: 0),
                summary: ".silentOnTouch は触れても読み上げない。.requiresActivation は、先に 2 回タップしてから直接触れる"),
        ],
        code: CodeTemplate(
            prefix: ["// Piano は鍵盤を並べ、触れた鍵盤の音を鳴らす自作の View"], indent: 0, call: "Piano"),
        build: { v in
            AnyView(
                DirectTouchDemo(
                    isDirect: v["accessibilityDirectTouch.isDirectTouchArea"] == nil
                        ? (v["accessibilityDirectTouch.options"] == nil ? nil : true)
                        : v.flag("accessibilityDirectTouch.isDirectTouchArea"),
                    options: v.pick(
                        "accessibilityDirectTouch.options",
                        from: [AccessibilityDirectTouchOptions.silentOnTouch, .requiresActivation]),
                    optionIndex: v.pick("accessibilityDirectTouch.options", from: [0, 1])))
        }
    )
}

private struct DirectTouchDemo: View {
    /// nil なら modifier をかけない（options だけ ON なら、既定の true でかける）
    let isDirect: Bool?
    let options: AccessibilityDirectTouchOptions?
    let optionIndex: Int?
    @State private var played = "–"

    var body: some View {
        A11yDemo(title: "VoiceOver が入っているとき", lines: lines) {
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    ForEach(["ド", "レ", "ミ", "ファ"], id: \.self) { note in
                        Text(note)
                            .frame(width: 44, height: 72, alignment: .bottom)
                            .padding(.bottom, 6)
                            .background(Color(.systemBackground), in: .rect(cornerRadius: 4))
                            .onTapGesture { played = note }
                    }
                }
                .apply(isDirect) { view, isDirect in
                    view.accessibilityDirectTouch(isDirect, options: options ?? [])
                }
                Text("鳴らした音: \(played)")
                    .font(.caption)
            }
        }
    }

    private var lines: [String] {
        guard isDirect == true else { return ["鍵盤を選んで、2 回タップで鳴らす"] }
        let option: [String] =
            switch optionIndex {
            case 0: ["触れても、鍵盤の名前を読まない"]
            case 1: ["先に 2 回タップしてから、直接触れられる"]
            default: []
            }
        return ["触れた鍵盤がすぐ鳴る（2 回タップしなくてよい）"] + option
    }
}
