import SwiftUI

/// 支援技術が触れる場所の印。親の大きさの中で、point の場所に赤い点を出す
struct A11yPointMarker: View {
    let point: UnitPoint
    var label: String? = nil

    var body: some View {
        GeometryReader { geometry in
            let x = geometry.size.width * point.x
            let y = geometry.size.height * point.y
            Circle()
                .fill(.red)
                .stroke(.white, lineWidth: 2)
                .frame(width: 14, height: 14)
                .position(x: x, y: y)
            if let label {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 4)
                    .background(.red, in: .capsule)
                    .fixedSize()
                    .position(x: min(max(x, 40), geometry.size.width - 40), y: y + 16)
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
