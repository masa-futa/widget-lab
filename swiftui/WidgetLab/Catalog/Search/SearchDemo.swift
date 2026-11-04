import SwiftUI

/// 検索の見本で使う品物。名前と、果物か野菜か（searchScopes で絞る）
let searchGoods: [(name: String, isFruit: Bool)] = [
    ("りんご", true), ("みかん", true), ("ぶどう", true), ("いちご", true),
    ("にんじん", false), ("トマト", false), ("キャベツ", false), ("たまねぎ", false),
]

/// 検索の見本の入れ物。打った文字（query）と、絞り込みの範囲（scope。0 がすべて・1 が果物・2 が野菜）を持ち、
/// 文字と範囲で絞った品物の一覧を NavigationStack に出す。一覧にかける modifier を modify で渡す
struct SearchStack<Root: View>: View {
    @ViewBuilder let modify: (AnyView, Binding<String>, Binding<Int>) -> Root
    @State private var query = ""
    @State private var scope = 0

    var body: some View {
        NavigationStack {
            modify(AnyView(List(names, id: \.self) { Text($0) }.navigationTitle("品物")), $query, $scope)
        }
    }

    private var names: [String] {
        searchGoods
            .filter { scope == 0 || $0.isFruit == (scope == 1) }
            .map(\.name)
            .filter { query.isEmpty || $0.contains(query) }
    }
}

/// 検索の候補の行。押すと、検索の欄にその名前が入る（searchCompletion）
struct SearchSuggestionRows: View {
    var completes = true

    var body: some View {
        ForEach(["りんご", "トマト"], id: \.self) { name in
            Label(name, systemImage: "magnifyingglass")
                .apply(completes ? name : nil) { $0.searchCompletion($1) }
        }
    }
}

nonisolated extension CodeTemplate {
    /// SearchStack の一覧に searchable をかけた収録のコード。call が .searchable で、modifier はその下に並ぶ
    static func inSearchStack(placement: String? = nil, suffix: [String] = []) -> CodeTemplate {
        CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(names, id: \\.self) { Text($0) }",
                "        .navigationTitle(\"品物\")",
            ], indent: 8, call: ".searchable",
            fixedArguments: ["text: $query"] + (placement.map { ["placement: \($0)"] } ?? []),
            suffix: suffix, closing: ["}"])
    }
}
