import SwiftUI

nonisolated extension CatalogEntry {
    static let simultaneousGesture = CatalogEntry(
        id: "simultaneousGesture",
        kind: .modifier,
        topic: .gestures,
        summary: "View にジェスチャーを付け、中の View のジェスチャーと同時に認識させる modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/simultaneousgesture(_:including:)")!,
        stage: .behavior,
        properties: [
            .modifier(
                "simultaneousGesture", .fixed(code: "TapGesture().onEnded { print(\"外側\") }"), on: true,
                summary: "外側に付けるジェスチャー。内側をタップすると、内側と外側の両方が動く"),
            .modifier(
                "simultaneousGesture", id: "simultaneousGesture.including", label: "including",
                .choice([Choice(".all"), Choice(".gesture"), Choice(".subviews"), Choice(".none")], initial: 0),
                required: true,
                summary: "効かせる範囲。.gesture は外側だけ（内側は止まる）、.subviews は内側だけ、.none はどちらも止まる"),
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    Text(\"内側\")\n        .onTapGesture { print(\"内側\") }\n}"),
        build: { v in
            AnyView(
                OuterGestureDemo(
                    kind: v["simultaneousGesture"] != nil ? .simultaneous : nil,
                    mask: v.pick("simultaneousGesture.including", from: [GestureMask.all, .gesture, .subviews, .none])
                        ?? .all))
        }
    )
}

/// 内側の的と外側の枠の両方にタップを付けた見本。外側のジェスチャーの付け方を kind で選ぶ（nil なら付けない）
struct OuterGestureDemo: View {
    enum Kind {
        case simultaneous
        case highPriority
    }

    let kind: Kind?
    let mask: GestureMask
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        let _ = reportBody(recorder, "見本")
        let outer = TapGesture().onEnded { recorder?.log("外側") }
        OuterGestureFrame {
            GestureTile(text: "内側")
                .onTapGesture { recorder?.log("内側") }
                .accessibilityAddTraits(.isButton)
        }
        .apply(kind) { view, kind in
            switch kind {
            case .simultaneous: view.simultaneousGesture(outer, including: mask)
            case .highPriority: view.highPriorityGesture(outer, including: mask)
            }
        }
    }
}
