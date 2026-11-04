import SwiftUI

/// 節の索引（listSectionIndexVisibility・sectionIndexLabel）の見本。頭の文字ごとの節を並べた List
struct SectionIndexDemo: View {
    nonisolated struct LetterGroup: Sendable {
        let letter: String
        let names: [String]
    }

    nonisolated static let groups = [
        LetterGroup(letter: "あ", names: ["あんず", "アボカド"]),
        LetterGroup(letter: "い", names: ["いちご", "いちじく"]),
        LetterGroup(letter: "か", names: ["かき", "かぼす"]),
        LetterGroup(letter: "さ", names: ["さくらんぼ"]),
        LetterGroup(letter: "す", names: ["すいか", "すだち"]),
        LetterGroup(letter: "な", names: ["なし"]),
        LetterGroup(letter: "ぶ", names: ["ぶどう"]),
        LetterGroup(letter: "み", names: ["みかん"]),
    ]

    /// 節に索引の文字を付けるか
    let labels: Bool
    /// 索引を出すか。nil なら付けない
    let visibility: Visibility?

    var body: some View {
        List {
            ForEach(Self.groups, id: \.letter) { group in
                Section(group.letter) {
                    ForEach(group.names, id: \.self) { Text($0) }
                }
                .apply(labels ? () : nil) { view, _ in view.sectionIndexLabel(group.letter) }
            }
        }
        .apply(visibility) { $0.listSectionIndexVisibility($1) }
    }
}
