import SwiftUI

nonisolated extension CatalogEntry {
    static let onKeyPress = CatalogEntry(
        id: "onKeyPress",
        kind: .modifier,
        topic: .inputEvents,
        summary: "フォーカスのある View で、ハードウェアのキーボードのキーが押されたときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onkeypress(phases:action:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onKeyPress", id: "onKeyPress.phases", label: "phases",
                .choice([Choice(".down"), Choice(".up"), Choice(".all")], initial: 0), required: true,
                summary: "受け取る段階（押した・離した・押し続けて繰り返した）"),
            .modifier(
                "onKeyPress", label: "action",
                .fixed(code: "{ press in print(press.characters); return .ignored }"), on: true,
                summary: "キーが押されたときの処理。.ignored を返すと、文字は入力欄にも入る"),
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"キーを押す\"", "text: $text"], suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                OnKeyPressDemo(
                    phases: v["onKeyPress"] != nil
                        ? v.pick("onKeyPress.phases", from: [KeyPress.Phases.down, .up, .all]) : nil))
        }
    )
}

private struct OnKeyPressDemo: View {
    /// nil なら onKeyPress を付けない
    let phases: KeyPress.Phases?
    @State private var text = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        TextField("キーを押す", text: $text)
            .apply(phases) { view, phases in
                view.onKeyPress(phases: phases) { press in
                    recorder?.log("「\(press.characters)」\(Self.name(press.phase))")
                    return .ignored
                }
            }
            .textFieldStyle(.bordered)
            .padding(.horizontal)
    }

    private static func name(_ phase: KeyPress.Phases) -> String {
        switch phase {
        case .down: "を押した"
        case .up: "を離した"
        case .repeat: "を押し続けた"
        default: ""
        }
    }
}
