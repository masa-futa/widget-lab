import SwiftUI

nonisolated extension CatalogEntry {
    static let spatialTapGesture = CatalogEntry(
        id: "SpatialTapGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "決まった回数のタップを認識し、タップした位置を知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/spatialtapgesture")!,
        stage: .card,
        properties: [
            .argument(
                "count", .slider(range: 1...3, step: 1, initial: 2), on: true, summary: "認識するタップの回数。省くと 1 回"),
            .argument(
                "coordinateSpace", .choice(coordinateSpaceChoices, initial: 1),
                summary: "位置の基準。省くと .local（枠の左上から）。.global は画面の左上からになり、点が枠の外にずれる"),
        ],
        code: CodeTemplate(
            prefix: ["Rectangle()"], call: ".gesture(SpatialTapGesture",
            trailing: ".onEnded { location = $0.location })"),
        build: { v in
            AnyView(
                SpatialTapGestureDemo(
                    count: v.number("count").map { Int($0) } ?? 1,
                    space: coordinateSpace(global: v.pick("coordinateSpace", from: [false, true]))))
        }
    )
}

private struct SpatialTapGestureDemo: View {
    let count: Int
    let space: any CoordinateSpaceProtocol
    @State private var location: CGPoint?

    var body: some View {
        Rectangle()
            .fill(.tint.opacity(0.2))
            .frame(width: 240, height: 140)
            .overlay(alignment: .topLeading) {
                if let location {
                    Circle()
                        .fill(.tint)
                        .frame(width: 16, height: 16)
                        .offset(x: location.x - 8, y: location.y - 8)
                }
            }
            .overlay(alignment: .bottom) {
                Text(location.map { "x: \(Int($0.x))  y: \(Int($0.y))" } ?? "\(count) 回タップすると点を置く")
                    .font(.caption)
                    .monospacedDigit()
                    .padding(6)
            }
            .clipped()
            .gesture(SpatialTapGesture(count: count, coordinateSpace: space).onEnded { location = $0.location })
            .accessibilityElement(children: .combine)
            .accessibilityAddTraits(.isButton)
    }
}
