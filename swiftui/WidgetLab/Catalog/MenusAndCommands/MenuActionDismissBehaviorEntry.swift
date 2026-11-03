import SwiftUI

nonisolated extension CatalogEntry {
    static let menuActionDismissBehavior = CatalogEntry(
        id: "menuActionDismissBehavior",
        kind: .modifier,
        topic: .menusAndCommands,
        summary: "メニューの項目を押したあと、メニューを閉じるかどうかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/menuactiondismissbehavior(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "menuActionDismissBehavior",
                .choice([Choice(".automatic"), Choice(".enabled"), Choice(".disabled")], initial: 2), on: true,
                summary: "押したあとに閉じるか。.disabled なら開いたまま続けて押せる")
        ],
        code: CodeTemplate(
            prefix: ["Menu(\"数: \\(count)\") {"], call: "Button", fixedArguments: ["\"+1\""],
            trailing: " { count += 1 }", closing: ["}"]),
        build: { v in
            AnyView(
                MenuActionDismissBehaviorDemo(
                    behavior: v.pick(
                        "menuActionDismissBehavior", from: [MenuActionDismissBehavior.automatic, .enabled, .disabled])))
        }
    )
}

private struct MenuActionDismissBehaviorDemo: View {
    let behavior: MenuActionDismissBehavior?
    @State private var count = 0

    var body: some View {
        Menu("数: \(count)") {
            Button("+1") { count += 1 }
                .apply(behavior) { $0.menuActionDismissBehavior($1) }
        }
        .buttonStyle(.bordered)
        .monospacedDigit()
    }
}
