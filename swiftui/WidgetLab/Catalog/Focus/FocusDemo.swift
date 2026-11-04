import SwiftUI

extension FocusedValues {
    /// focus の収録で使う、フォーカスのあるメモの題名
    @Entry var demoNoteTitle: String?
    /// focus の収録で使う、フォーカスのあるメモの本文
    @Entry var demoNoteText: Binding<String>?
}

/// focus の収録で使う、題名を持つメモ（ObservableObject）
final class DemoNote: ObservableObject {
    @Published var title: String

    init(_ title: String) {
        self.title = title
    }
}

/// 読んだ値を出す札（focus の見本で共通の見た目）
struct FocusReadout: View {
    let title: String
    let value: String?

    var body: some View {
        Text("\(title): \(value ?? "なし")")
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(.yellow.opacity(0.4), in: .rect(cornerRadius: 6))
    }
}

/// メモの入力欄（focus の見本で共通の見た目）
struct NoteField: View {
    let title: String
    @Binding var text: String

    var body: some View {
        TextField(title, text: $text)
            .textFieldStyle(.bordered)
    }
}
