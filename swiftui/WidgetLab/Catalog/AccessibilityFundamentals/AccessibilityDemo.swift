import SwiftUI

/// アクセシビリティの収録で使う入れ物。上に見本、下に「支援技術に渡る中身」の札を出す。
/// SwiftUI は VoiceOver などの支援技術が動いていないとアクセシビリティの要素を作らず、アプリの中から読めない。
/// そこで札は、見本に渡したのと同じ値から書く。札そのものは読み上げない（支援技術の木に入れない）
struct A11yDemo<Content: View>: View {
    /// 札の見出し（例: "VoiceOver が読む要素"）
    let title: String
    /// 札の中身。1 行に 1 つ
    let lines: [String]
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 14) {
            content
            A11yCaption(title: title, lines: lines)
        }
        .padding(12)
    }
}

/// 支援技術に渡る中身の札
struct A11yCaption: View {
    let title: String
    let lines: [String]

    var body: some View {
        VStack(spacing: 3) {
            Label(title, systemImage: "accessibility")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            ForEach(Array(lines.enumerated()), id: \.offset) { _, line in
                Text(line)
                    .font(.caption)
            }
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: 260)
        .background(Color(.systemBackground), in: .rect(cornerRadius: 10))
        .accessibilityHidden(true)
    }
}

/// 札の行の書き方
nonisolated enum A11yText {
    /// 要素 1 つ。例: 「星」 値「3」 .isButton ヒント「…」
    static func element(_ label: String?, value: String? = nil, traits: [String] = [], hint: String? = nil) -> String {
        var parts = [label.map { "「\($0)」" } ?? "（ラベルなし）"]
        if let value { parts.append("値「\(value)」") }
        parts += traits
        if let hint { parts.append("ヒント「\(hint)」") }
        return parts.joined(separator: " ")
    }

    /// 読む順に番号を付ける（1 つなら付けない）
    static func ordered(_ items: [String]) -> [String] {
        items.count < 2 ? items : items.enumerated().map { "\($0.offset + 1). \($0.element)" }
    }
}
