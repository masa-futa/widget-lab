import SwiftUI

nonisolated extension CatalogEntry {
    static let disabled = CatalogEntry(
        id: "disabled",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "中にある View を、触れなくする modifier。コントロールは薄い色になる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/disabled(_:)")!,
        stage: .card,
        properties: [
            .modifier("disabled", .toggle(initial: true), on: true, summary: "true で触れなくする。中のコントロールすべてに効く")
        ],
        code: CodeTemplate(
            call: "VStack",
            trailing:
                " {\n    Button(\"保存\") { }\n        .buttonStyle(.borderedProminent)\n    Toggle(\"通知\", isOn: $isOn)\n}"
        ),
        build: { v in
            AnyView(DisabledDemo(disabled: v.flag("disabled")))
        }
    )
}

private struct DisabledDemo: View {
    let disabled: Bool?
    @State private var isOn = true

    var body: some View {
        VStack {
            Button("保存") {}
                .buttonStyle(.borderedProminent)
            Toggle("通知", isOn: $isOn)
        }
        .apply(disabled) { $0.disabled($1) }
        .frame(width: 240)
    }
}
