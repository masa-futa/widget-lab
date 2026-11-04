import SwiftUI

/// ジェスチャーの見本で使う的（色の付いた角丸の四角と、中の説明）
struct GestureTile: View {
    let text: String
    var isActive = false

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(isActive ? AnyShapeStyle(.orange) : AnyShapeStyle(.tint.opacity(0.25)))
            .frame(width: 120, height: 72)
            .overlay {
                Text(text)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .contentShape(.rect(cornerRadius: 12))
    }
}

/// 内側と外側にジェスチャーを持つ見本の外側の枠（simultaneousGesture・highPriorityGesture で使う）
struct OuterGestureFrame<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 6) {
            Text("外側")
                .font(.caption)
                .foregroundStyle(.secondary)
            content
        }
        .padding(12)
        .background(.background, in: .rect(cornerRadius: 16))
        .contentShape(.rect(cornerRadius: 16))
    }
}

/// 座標の基準を選ぶ選択肢（SpatialTapGesture・SpatialEventGesture で使う）
nonisolated let coordinateSpaceChoices = [Choice(".local"), Choice(".global")]

/// 選んだ座標の基準（nil なら省く = .local）
func coordinateSpace(global: Bool?) -> any CoordinateSpaceProtocol {
    global == true ? .global as GlobalCoordinateSpace : .local as LocalCoordinateSpace
}
