import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationStack = CatalogEntry(
        id: "NavigationStack",
        kind: .view,
        topic: .navigation,
        summary: "最初の画面の上に、進んだ先の画面を積み重ねて出す View。戻ると上から 1 つずつ外れる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/navigationstack")!,
        stage: .full,
        properties: [
            .argument(
                "path", .fixed(code: "$path"), on: true,
                summary: "積んだ画面の値の配列の Binding。書き換えると、コードから進んだり戻ったりできる（OFF のとき、コードの toolbar の行は使えない。見本ではボタンを消している）"),
            .modifier("tint", .color(initial: 3), summary: "戻るボタンなどの色"),
        ],
        code: CodeTemplate(
            call: "NavigationStack",
            trailing:
                " {\n    List(fruits, id: \\.self) { NavigationLink($0, value: $0) }\n        .navigationDestination(for: String.self) { Text($0) }\n        .toolbar { Button(\"ぶどうの先まで\") { path = [\"ぶどう\", \"ぶどうの先\"] } }\n}"
        ),
        build: { v in
            AnyView(NavigationStackDemo(usesPath: v["path"] != nil, tint: v.color("tint")))
        }
    )
}

private struct NavigationStackDemo: View {
    let usesPath: Bool
    let tint: Color?
    @State private var path: [String] = []

    var body: some View {
        Group {
            if usesPath {
                NavigationStack(path: $path) { root }
            } else {
                NavigationStack { root }
            }
        }
        .apply(tint) { $0.tint($1) }
    }

    private var root: some View {
        List(navigationFruits, id: \.self) { NavigationLink($0, value: $0) }
            .navigationDestination(for: String.self) { FruitScreen(name: $0) }
            .navigationTitle("果物")
            .toolbar {
                if usesPath {
                    Button("ぶどうの先まで") { path = ["ぶどう", "ぶどうの先"] }
                }
            }
    }
}
