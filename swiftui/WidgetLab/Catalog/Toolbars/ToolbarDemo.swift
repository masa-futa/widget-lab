import SwiftUI

/// ツールバーの見本の入れ物。長いメモの一覧（スクロールで変わる modifier のため）を NavigationStack に出し、
/// 右上と下のバーのボタンと、題名「メモ」を付ける。一覧にかける modifier を modify で渡す
struct ToolbarStack<Root: View>: View {
    @ViewBuilder let modify: (AnyView) -> Root

    var body: some View {
        NavigationStack {
            modify(
                AnyView(
                    List(1...40, id: \.self) { Text("メモ \($0)") }
                        .toolbar {
                            ToolbarItem(placement: .topBarTrailing) { Button("足す", systemImage: "plus") {} }
                            ToolbarItem(placement: .bottomBar) {
                                Button("並べ替え", systemImage: "arrow.up.arrow.down") {}
                            }
                        }
                        .navigationTitle("メモ")
                ))
        }
    }
}

nonisolated extension CodeTemplate {
    /// ToolbarStack の一覧にかける modifier の収録のコード。call が .navigationTitle で、modifier はその下に並ぶ
    static func inToolbarStack(suffix: [String] = []) -> CodeTemplate {
        CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(1...40, id: \\.self) { Text(\"メモ \\($0)\") }", "        .toolbar {",
                "            ToolbarItem(placement: .topBarTrailing) { Button(\"足す\", systemImage: \"plus\") { } }",
                "            ToolbarItem(placement: .bottomBar) { Button(\"並べ替え\", systemImage: \"arrow.up.arrow.down\") { } }",
                "        }",
            ], indent: 8, call: ".navigationTitle", fixedArguments: ["\"メモ\""], suffix: suffix, closing: ["}"])
    }
}
