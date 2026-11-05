import SwiftUI

/// 次の画面へ進む一覧の行。文字は tint にせず、右端に矢印を出す（NavigationLink の行と同じ見た目）
/// 押したときの地を行いっぱいに塗るため、行の余白はこのスタイルが持つ。使う側で `.listRowInsets(EdgeInsets())` を付ける
struct NavigationRowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .foregroundStyle(.primary)
        // List の行の既定の余白と同じ（iOS 27 で撮って合わせた）
        .padding(.leading, 16)
        .padding(.trailing, 20)
        .padding(.vertical, 15)
        // 区切り線は、余白を除いた中身の頭から引く
        .alignmentGuide(.listRowSeparatorLeading) { $0[.leading] + 16 }
        .contentShape(.rect)
        .background {
            if configuration.isPressed {
                Color(.systemFill)
            }
        }
    }
}

extension ButtonStyle where Self == NavigationRowButtonStyle {
    static var navigationRow: NavigationRowButtonStyle { NavigationRowButtonStyle() }
}
