import SwiftUI

/// 次の画面へ進む一覧の行。文字は tint にせず、右端に矢印を出す（NavigationLink の行と同じ見た目）
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
        .contentShape(.rect)
        .background {
            if configuration.isPressed {
                // 行の余白まで塗る（はみ出した分は行の枠で切れる）
                Color(.systemFill).padding(.horizontal, -20).padding(.vertical, -12)
            }
        }
    }
}

extension ButtonStyle where Self == NavigationRowButtonStyle {
    static var navigationRow: NavigationRowButtonStyle { NavigationRowButtonStyle() }
}
