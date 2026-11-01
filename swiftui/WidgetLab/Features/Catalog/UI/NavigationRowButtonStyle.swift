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
    }
}

extension ButtonStyle where Self == NavigationRowButtonStyle {
    static var navigationRow: NavigationRowButtonStyle { NavigationRowButtonStyle() }
}
