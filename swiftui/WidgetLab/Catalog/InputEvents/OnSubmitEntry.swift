import SwiftUI

nonisolated extension CatalogEntry {
    static let onSubmit = CatalogEntry(
        id: "onSubmit",
        kind: .modifier,
        topic: .inputEvents,
        summary: "入力欄で確定した（キーボードの改行キーを押した）ときに、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onsubmit(of:_:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "onSubmit", id: "onSubmit.of", label: "of", .choice([Choice(".text"), Choice(".search")], initial: 0),
                required: true, summary: "受け取る確定の種類。.search は検索欄（searchable）の確定だけなので、この入力欄では動かない"),
            .modifier(
                "onSubmit", .fixed(code: "{ print(\"送った\") }"), on: true, summary: "確定したときの処理"),
        ],
        code: CodeTemplate(
            call: "TextField", fixedArguments: ["\"名前\"", "text: $name"], suffix: [".textFieldStyle(.bordered)"]),
        build: { v in
            AnyView(
                OnSubmitDemo(
                    triggers: v["onSubmit"] != nil
                        ? v.pick("onSubmit.of", from: [SubmitTriggers.text, .search]) : nil))
        }
    )
}

private struct OnSubmitDemo: View {
    /// nil なら onSubmit を付けない
    let triggers: SubmitTriggers?
    @State private var name = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        TextField("名前", text: $name)
            .apply(triggers) { view, triggers in
                view.onSubmit(of: triggers) { recorder?.log("「\(name)」を送った") }
            }
            .textFieldStyle(.bordered)
            .padding(.horizontal)
    }
}
