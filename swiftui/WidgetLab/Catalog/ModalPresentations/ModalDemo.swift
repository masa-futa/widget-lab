import SwiftUI

/// 画面を重ねて出す見本で使う、シートの中身。中の見出しと、閉じるボタンを出す
/// （閉じるボタンは、指で下げて閉じられないシートや全画面のカバーでも閉じられるようにするため）
struct ModalSheetContent<Extra: View>: View {
    let title: String
    @ViewBuilder let extra: Extra
    @Environment(\.dismiss) private var dismiss

    init(_ title: String, @ViewBuilder extra: () -> Extra = { EmptyView() }) {
        self.title = title
        self.extra = extra()
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.headline)
            extra
            Button("閉じる") { dismiss() }
                .buttonStyle(.bordered)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// シートの中身に modifier をかける見本。ボタンでシートを開き、中身は content で組み立てる
/// （presentationDetents など、シートの中身にかける modifier の収録で使う）
struct SheetModifierDemo<Content: View>: View {
    var title = "シートを開く"
    @ViewBuilder let content: () -> Content
    @State private var shows = false

    var body: some View {
        Button(title) { shows = true }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $shows, content: content)
    }
}

nonisolated extension CodeTemplate {
    /// シートの中身の Text にかける modifier の収録のコード。call が Text で、modifier はその下に並ぶ
    static func inSheet(_ text: String = "シートの中身") -> CodeTemplate {
        CodeTemplate(
            prefix: ["Button(\"シートを開く\") { shows = true }", "    .sheet(isPresented: $shows) {"], indent: 8,
            call: "Text", fixedArguments: ["\"\(text)\""], closing: ["    }"])
    }
}
