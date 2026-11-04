import SwiftUI

/// 画面の行き来の見本で使う果物の名前
let navigationFruits = ["りんご", "みかん", "ぶどう"]

/// 果物 1 つの画面（一覧から進んだ先）
struct FruitScreen: View {
    let name: String

    var body: some View {
        Text(name)
            .font(.largeTitle)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.secondarySystemBackground))
    }
}

/// 果物の一覧から、押した果物の画面へ進む NavigationStack。root にかける modifier を modify で渡す
/// （navigationTitle など、スタックの中の画面にかける modifier の収録で使う）
struct FruitStack<Root: View>: View {
    @ViewBuilder let modify: (AnyView) -> Root

    var body: some View {
        NavigationStack {
            modify(
                AnyView(
                    List(navigationFruits, id: \.self) { name in
                        NavigationLink(name, value: name)
                    })
            )
            .navigationDestination(for: String.self) { FruitScreen(name: $0) }
        }
    }
}

/// タブの見本で使う 3 つのタブ。2 つ目は長い一覧（スクロールで変わる modifier のため）
struct FruitTabs: TabContent {
    typealias TabValue = Never

    var body: some TabContent<Never> {
        Tab("ホーム", systemImage: "house") { FruitScreen(name: "ホーム") }
        Tab("一覧", systemImage: "list.bullet") {
            List(1...40, id: \.self) { Text("行 \($0)") }
        }
        Tab("設定", systemImage: "gear") { FruitScreen(name: "設定") }
    }
}
