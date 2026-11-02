import SwiftUI

/// 詳細。上にプレビューとコードの 1 行、その下にチップの列、下半分に編集パネル
struct DetailScreen: View {
    @Bindable var viewModel: DetailViewModel
    @State private var showsInfo = false
    @State private var showsCode = false

    var body: some View {
        VStack(spacing: 0) {
            PreviewArea(viewModel: viewModel)
                .frame(maxWidth: .infinity)
                .frame(height: 280)
            CodeStrip(line: viewModel.selectedLine) { showsCode = true }
            PropertyChips(viewModel: viewModel)
            Divider()
            EditorPanel(viewModel: viewModel)
        }
        .navigationTitle(viewModel.entry.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("初期状態に戻す", systemImage: "arrow.counterclockwise") { viewModel.reset() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("説明", systemImage: "info.circle") { showsInfo = true }
            }
        }
        .sheet(isPresented: $showsInfo) {
            InfoSheet(entry: viewModel.entry)
        }
        .sheet(isPresented: $showsCode) {
            CodeSheet(viewModel: viewModel)
        }
    }
}

/// 選んでいるプロパティのコードの 1 行。押すと全文のシートを開く
private struct CodeStrip: View {
    let line: CodeLine?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(line?.text.trimmingCharacters(in: .whitespaces) ?? "")
                    .font(.system(.footnote, design: .monospaced))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.up")
                    .font(.footnote)
            }
            .padding(.horizontal, 16)
            .frame(minHeight: 44)
            .background(.fill.tertiary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("コードの全文を開く")
        .accessibilityIdentifier("code-strip")
    }
}

/// ⓘ から開く説明
private struct InfoSheet: View {
    let entry: CatalogEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(entry.summary)
                    Link("公式ドキュメントを開く", destination: entry.docURL)
                }
                Section("プロパティ") {
                    ForEach(entry.properties) { spec in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(spec.displayName).font(.system(.body, design: .monospaced))
                            Text(spec.summary).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(entry.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("閉じる") { dismiss() }
                }
            }
        }
    }
}
