import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityZoomAction = CatalogEntry(
        id: "accessibilityZoomAction",
        kind: .modifier,
        topic: .accessibleControls,
        summary: "支援技術の拡大・縮小の操作に応える modifier。地図や写真のように、倍率を変えられる View に付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityzoomaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityZoomAction", .fixed(code: "{ action in zoom += action.direction == .zoomIn ? 1 : -1 }"),
                on: true,
                summary: "拡大・縮小の処理。向き（.zoomIn・.zoomOut）と場所が渡る")
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"map\""], suffix: [".scaleEffect(CGFloat(zoom))"]),
        build: { v in
            AnyView(ZoomActionDemo(isZoomable: v["accessibilityZoomAction"] != nil))
        }
    )
}

private struct ZoomActionDemo: View {
    let isZoomable: Bool
    @State private var zoom = 1

    var body: some View {
        A11yDemo(title: "VoiceOver で行える操作", lines: lines) {
            Image(systemName: "map")
                .font(.title)
                .scaleEffect(CGFloat(zoom))
                .frame(width: 120, height: 80)
                .accessibilityLabel("地図")
                .accessibilityValue("\(zoom) 倍")
                .apply(isZoomable ? () : nil) { view, _ in
                    view.accessibilityZoomAction { action in
                        zoom = min(max(zoom + (action.direction == .zoomIn ? 1 : -1), 1), 3)
                    }
                }
        }
    }

    private var lines: [String] {
        [A11yText.element("地図", value: "\(zoom) 倍", traits: [".isImage"])]
            + (isZoomable ? ["VoiceOver の拡大・縮小の操作で、倍率を変える"] : ["（VoiceOver からは倍率を変えられない）"])
    }
}
