import SwiftUI

nonisolated extension CatalogEntry {
    static let gesture = CatalogEntry(
        id: "gesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View にジェスチャーを付ける modifier。View がもともと持つジェスチャーより後に回る。isEnabled で、効くかどうかを切り替えられる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/gesture(_:isenabled:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "gesture", .fixed(code: "TapGesture(count: 2).onEnded { print(\"2 回タップ\") }"), on: true,
                summary: "付けるジェスチャー"),
            .modifier(
                "gesture", id: "gesture.isEnabled", label: "isEnabled", .toggle(initial: true), required: true,
                summary: "false にすると、付けたまま効かなくなる"),
        ],
        code: CodeTemplate(call: "RoundedRectangle", fixedArguments: ["cornerRadius: 12"]),
        build: { v in
            AnyView(GestureModifierDemo(attaches: v["gesture"] != nil, isEnabled: v.flag("gesture.isEnabled") ?? true))
        }
    )
}

private struct GestureModifierDemo: View {
    let attaches: Bool
    let isEnabled: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "2 回タップ")
            .apply(attaches ? () : nil) { view, _ in
                view.gesture(TapGesture(count: 2).onEnded { recorder?.log("2 回タップを認識") }, isEnabled: isEnabled)
            }
            .accessibilityAddTraits(.isButton)
    }
}
