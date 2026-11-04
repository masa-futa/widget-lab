import SwiftUI

/// clipboard の収録で使う見本。果物の札にフォーカスを当て、キーボードの ⌘C・⌘X・⌘V で試す
struct ClipboardDemo: View {
    enum Command { case copy, cut, paste }

    /// nil なら modifier をかけない
    let command: Command?
    @State private var fruits = ["りんご", "ぶどう"]
    @FocusState private var isFocused: Bool
    @Environment(\.demoRecorder) private var recorder

    var body: some View {
        VStack(spacing: 8) {
            Button("札にフォーカス") { isFocused = true }
                .buttonStyle(.bordered)
            Text(fruits.isEmpty ? "（空）" : fruits.joined(separator: "・"))
                .padding(8)
                .background(isFocused ? Color.yellow : Color.gray.opacity(0.3), in: .rect(cornerRadius: 6))
                .focusable()
                .focused($isFocused)
                .apply(command) { view, command in
                    switch command {
                    case .copy:
                        view.copyable(copied())
                    case .cut:
                        view.cuttable(for: String.self) {
                            let cut = fruits
                            fruits = []
                            recorder?.log("\(cut.joined(separator: "・")) を切り取った")
                            return cut
                        }
                    case .paste:
                        view.pasteDestination(for: String.self) { items in
                            fruits += items
                            recorder?.log("\(items.joined(separator: "・")) を貼り付けた")
                        }
                    }
                }
        }
    }

    /// コピーされるときに呼ばれる（copyable は値を後から作る）
    private func copied() -> [String] {
        recorder?.log("\(fruits.joined(separator: "・")) をコピーした")
        return fruits
    }
}
