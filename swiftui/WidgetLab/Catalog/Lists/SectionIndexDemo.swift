import SwiftUI

/// 節の索引（listSectionIndexVisibility・sectionIndexLabel）の見本。頭の文字ごとの節を並べた List
struct SectionIndexDemo: View {
    nonisolated struct Group: Sendable {
        let letter: String
        let names: [String]
    }

    nonisolated static let groups = [
        Group(letter: "あ", names: ["あんず", "アボカド"]),
        Group(letter: "い", names: ["いちご", "いちじく"]),
        Group(letter: "か", names: ["かき", "かぼす"]),
        Group(letter: "さ", names: ["さくらんぼ"]),
        Group(letter: "す", names: ["すいか", "すだち"]),
        Group(letter: "な", names: ["なし"]),
        Group(letter: "ぶ", names: ["ぶどう"]),
        Group(letter: "み", names: ["みかん"]),
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
