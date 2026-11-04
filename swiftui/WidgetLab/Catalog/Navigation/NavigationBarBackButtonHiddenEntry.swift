import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationBarBackButtonHidden = CatalogEntry(
        id: "navigationBarBackButtonHidden",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックで進んだ先の画面の、戻るボタンを隠す modifier。指で端からなぞって戻ることもできなくなる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/navigationbarbackbuttonhidden(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationBarBackButtonHidden", .toggle(initial: true), on: true,
                summary: "true なら戻るボタンを隠す。代わりの戻り方（dismiss など）を用意する")
        ],
        code: CodeTemplate(
            prefix: [
                "NavigationStack {", "    List(fruits, id: \\.self) { NavigationLink($0, value: $0) }",
                "        .navigationDestination(for: String.self) { name in",
            ], indent: 12, call: "FruitScreen", fixedArguments: ["name: name"], closing: ["        }", "}"]),
        build: { v in
            AnyView(BackButtonHiddenDemo(hidden: v.flag("navigationBarBackButtonHidden")))
        }
    )
}

private struct BackButtonHiddenDemo: View {
    let hidden: Bool?

    var body: some View {
        NavigationStack {
            List(navigationFruits, id: \.self) { NavigationLink($0, value: $0) }
                .navigationTitle("果物")
                .navigationDestination(for: String.self) { name in
                    BackButtonHiddenScreen(name: name)
                        .apply(hidden) { $0.navigationBarBackButtonHidden($1) }
                }
        }
    }
}

/// 進んだ先の画面。戻るボタンを隠しても戻れるよう、下に戻るボタンを置く
private struct BackButtonHiddenScreen: View {
    let name: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            FruitScreen(name: name)
            Button("一覧に戻る") { dismiss() }
                .buttonStyle(.bordered)
                .padding(.bottom, 24)
        }
    }
}
