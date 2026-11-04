import SwiftUI

nonisolated extension CatalogEntry {
    static let spatialEventGesture = CatalogEntry(
        id: "SpatialEventGesture",
        kind: .gesture,
        topic: .gestures,
        summary: "触れている指 1 本ずつの位置と段階（触れている・離れた）を、続けて知らせるジェスチャー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/spatialeventgesture")!,
        stage: .card,
        properties: [
            .argument(
                "coordinateSpace", .choice(coordinateSpaceChoices, initial: 1),
                summary: "位置の基準。省くと .local（枠の左上から）。.global は画面の左上からになり、丸が枠の外にずれる")
        ],
        code: CodeTemplate(
            prefix: ["Rectangle()"], call: ".gesture(SpatialEventGesture",
            trailing:
                ".onChanged { events in touches = events.filter { $0.phase == .active }.map(\\.location) }.onEnded { _ in touches = [] })"
        ),
        build: { v in
            AnyView(
                SpatialEventGestureDemo(space: coordinateSpace(global: v.pick("coordinateSpace", from: [false, true]))))
        }
    )
}

private struct SpatialEventGestureDemo: View {
    let space: any CoordinateSpaceProtocol
    @State private var touches: [CGPoint] = []

    var body: some View {
        Rectangle()
            .fill(.tint.opacity(0.2))
            .frame(width: 240, height: 150)
            .overlay(alignment: .topLeading) {
                ForEach(touches.indices, id: \.self) { i in
                    Circle()
                        .fill(.tint.opacity(0.6))
                        .frame(width: 44, height: 44)
                        .offset(x: touches[i].x - 22, y: touches[i].y - 22)
                }
            }
            .overlay(alignment: .bottom) {
                Text(touches.isEmpty ? "指で触れる（2 本でも）" : "触れている指: \(touches.count) 本")
                    .font(.caption)
                    .padding(6)
            }
            .clipped()
            .gesture(
                SpatialEventGesture(coordinateSpace: space)
                    .onChanged { events in touches = events.filter { $0.phase == .active }.map(\.location) }
                    .onEnded { _ in touches = [] }
            )
    }
}
