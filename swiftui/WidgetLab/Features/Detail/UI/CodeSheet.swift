import SwiftUI

/// コードの全文。最初の値から変えた行に印を付ける。コピーのボタンを置く
struct CodeSheet: View {
    let viewModel: DetailViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(Array(viewModel.codeLines.enumerated()), id: \.offset) { _, line in
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(line.isChanged ? AnyShapeStyle(.tint) : AnyShapeStyle(.clear))
                                .frame(width: 3)
                                .accessibilityHidden(true)
                            Text(line.text)
                                .font(.system(.body, design: .monospaced))
                                .accessibilityLabel(line.isChanged ? "変更あり: \(line.text)" : line.text)
                        }
                    }
                }
                .padding()
                .textSelection(.enabled)
            }
            .navigationTitle("コード")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.didCopy ? "コピーしました" : "コピー") { viewModel.copyCode() }
                        .accessibilityIdentifier("copy")
                }
            }
        }
    }
}
