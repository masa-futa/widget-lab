import SwiftUI

nonisolated extension CatalogEntry {
    static let exclusiveGesture = CatalogEntry(
        id: "ExclusiveGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "2 つのジェスチャーのうち、片方だけを成り立たせるジェスチャー。1 つ目を先に試し、だめなら 2 つ目を試す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/exclusivegesture")!,
        stage: .behavior,
        properties: [
            .argument(
                "gestures", unlabeled: true,
                .choice(
                    [
                        Choice("2 回タップが先", code: "TapGesture(count: 2), TapGesture()"),
                        Choice("1 回タップが先", code: "TapGesture(), TapGesture(count: 2)"),
                    ], initial: 0), required: true,
                summary: "2 つのジェスチャーと、その順番。1 回タップを先にすると、2 回タップは成り立たない")
        ],
        code: CodeTemplate(
            prefix: ["RoundedRectangle(cornerRadius: 12)"], call: ".gesture(ExclusiveGesture",
            trailing: ".onEnded { print($0) })"),
        build: { v in
            AnyView(ExclusiveGestureDemo(doubleFirst: v.pick("gestures", from: [true, false]) ?? true))
        }
    )
}

private struct ExclusiveGestureDemo: View {
    let doubleFirst: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        GestureTile(text: "1 回か 2 回タップ")
            .gesture(gesture)
            .accessibilityAddTraits(.isButton)
    }

    private var gesture: some Gesture {
        let first = TapGesture(count: doubleFirst ? 2 : 1)
        let second = TapGesture(count: doubleFirst ? 1 : 2)
        return ExclusiveGesture(first, second).onEnded { value in
            switch value {
            case .first: recorder?.log("1 つ目（\(doubleFirst ? 2 : 1) 回タップ）を認識")
            case .second: recorder?.log("2 つ目（\(doubleFirst ? 1 : 2) 回タップ）を認識")
            }
        }
    }
}
