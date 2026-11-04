import SwiftUI

nonisolated extension CatalogEntry {
    static let transaction = CatalogEntry(
        id: "transaction",
        kind: .modifier,
        topic: .animations,
        summary: "この View の中の変化にかかるアニメーション（Transaction）を、書き換える modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/transaction(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "transaction",
                .choice(
                    [
                        Choice("動きを消す", code: "{ $0.animation = nil }"),
                        Choice("ゆっくり", code: "{ $0.animation = .linear(duration: 2) }"),
                        Choice("跳ねる", code: "{ $0.animation = .bouncy(extraBounce: 0.3) }"),
                    ],
                    initial: 1),
                on: true, summary: "書き換え方。下の円だけが変わり、上の円は withAnimation のまま動く")
        ],
        code: CodeTemplate(
            prefix: [
                "VStack {",
                "    Circle()",
                "        .fill(.blue)",
                "        .frame(width: 40, height: 40)",
                "        .offset(x: moved ? 80 : -80)",
                "    Circle()",
                "        .fill(.orange)",
                "        .frame(width: 40, height: 40)",
            ],
            indent: 8, call: ".offset", fixedArguments: ["x: moved ? 80 : -80"],
            closing: ["    Button(\"動かす\") { withAnimation { moved.toggle() } }", "}"]),
        build: { v in
            AnyView(TransactionDemo(change: v.pick("transaction", from: TransactionDemo.Change.allCases)))
        }
    )
}

private struct TransactionDemo: View {
    enum Change: CaseIterable {
        case removes, slow, bouncy
    }

    /// nil なら modifier をかけない
    let change: Change?
    @State private var moved = false

    var body: some View {
        VStack {
            Circle()
                .fill(.blue)
                .frame(width: 40, height: 40)
                .offset(x: moved ? 80 : -80)
            Circle()
                .fill(.orange)
                .frame(width: 40, height: 40)
                .offset(x: moved ? 80 : -80)
                .apply(change) { view, change in
                    view.transaction { transaction in
                        switch change {
                        case .removes: transaction.animation = nil
                        case .slow: transaction.animation = .linear(duration: 2)
                        case .bouncy: transaction.animation = .bouncy(extraBounce: 0.3)
                        }
                    }
                }
            Button("動かす") { withAnimation { moved.toggle() } }
                .buttonStyle(.bordered)
        }
        .frame(width: 220)
    }
}
