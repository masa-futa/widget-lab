import SwiftUI

nonisolated extension CatalogEntry {
    static let submitScope = CatalogEntry(
        id: "submitScope",
        kind: .modifier,
        topic: .inputEvents,
        summary: "中の入力欄で確定しても、外側に付けた onSubmit を動かさないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/submitscope(_:)")!,
        stage: .behavior,
        properties: [
            .modifier("submitScope", .toggle(initial: true), on: true, summary: "true なら、この入力欄の確定を外へ伝えない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    TextField(\"名前\", text: $name)"], indent: 4, call: "TextField",
            fixedArguments: ["\"メモ\"", "text: $memo"], closing: ["}", ".onSubmit { print(\"送った\") }"]),
        build: { v in
            AnyView(SubmitScopeDemo(isBlocking: v.flag("submitScope")))
        }
    )
}

private struct SubmitScopeDemo: View {
    /// nil なら submitScope を付けない
    let isBlocking: Bool?
    @State private var name = ""
    @State private var memo = ""
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        VStack(spacing: 8) {
            TextField("名前", text: $name)
            TextField("メモ", text: $memo)
                .apply(isBlocking) { $0.submitScope($1) }
        }
        .textFieldStyle(.bordered)
        .onSubmit { recorder?.log("送った（名前: \(name)、メモ: \(memo)）") }
        .padding(.horizontal)
    }
}
