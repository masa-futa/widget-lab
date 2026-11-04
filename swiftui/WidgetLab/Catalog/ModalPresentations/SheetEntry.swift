import SwiftUI

nonisolated extension CatalogEntry {
    static let sheet = CatalogEntry(
        id: "sheet",
        kind: .modifier,
        topic: .modalPresentations,
        summary: "Bool の Binding が true になったとき、今の画面の上にシートを重ねて出す modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/sheet(ispresented:ondismiss:content:)")!,
        stage: .card,
        properties: [
            .modifier(
                "sheet",
                .choice(
                    [
                        Choice("isPresented", code: "isPresented: $shows, content: { Text(\"シートの中身\") }"),
                        Choice(
                            "onDismiss も渡す",
                            code: "isPresented: $shows, onDismiss: { closed += 1 }, content: { Text(\"シートの中身\") }"),
                    ], initial: 1), on: true,
                summary: "出すかどうかの Binding と中身。onDismiss は閉じたあとに呼ばれる")
        ],
        code: CodeTemplate(call: "Button", fixedArguments: ["\"シートを開く\""], trailing: " { shows = true }"),
        build: { v in
            AnyView(SheetDemo(kind: v.pick("sheet", from: [SheetDemo.Kind.plain, .onDismiss])))
        }
    )
}

private struct SheetDemo: View {
    enum Kind {
        case plain, onDismiss
    }

    let kind: Kind?
    @State private var shows = false
    @State private var closed = 0

    var body: some View {
        VStack(spacing: 12) {
            Button("シートを開く") { shows = true }
                .buttonStyle(.borderedProminent)
                .apply(kind) { view, kind in
                    switch kind {
                    case .plain:
                        view.sheet(isPresented: $shows) { ModalSheetContent("シートの中身") }
                    case .onDismiss:
                        view.sheet(isPresented: $shows, onDismiss: { closed += 1 }) { ModalSheetContent("シートの中身") }
                    }
                }
            Text("閉じた回数: \(closed)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}
