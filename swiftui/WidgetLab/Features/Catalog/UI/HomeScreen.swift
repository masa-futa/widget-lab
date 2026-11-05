import SwiftUI

/// ホーム。大分類ごとのトピックの行と、検索
struct HomeScreen: View {
    @Bindable var viewModel: CatalogViewModel
    let onTopicTapped: (Topic) -> Void
    let onEntryTapped: (String) -> Void

    var body: some View {
        List {
            if !viewModel.isSearching {
                ForEach(viewModel.sections) { section in
                    Section(section.category.rawValue) {
                        ForEach(section.topics) { summary in
                            Button {
                                onTopicTapped(summary.topic)
                            } label: {
                                TopicRow(summary: summary)
                            }
                            .buttonStyle(.navigationRow)
                            .accessibilityIdentifier("topic-\(summary.topic.rawValue)")
                        }
                    }
                }
            } else if viewModel.results.isEmpty {
                ContentUnavailableView.search(text: viewModel.query)
            } else {
                ForEach(viewModel.results) { entry in
                    Button {
                        onEntryTapped(entry.id)
                    } label: {
                        EntryRow(entry: entry)
                    }
                    .buttonStyle(.navigationRow)
                    .accessibilityIdentifier("entry-\(entry.id)")
                }
            }
        }
        .navigationTitle("Widget Lab")
        .searchable(text: $viewModel.query, prompt: "名前で探す")
    }
}

private struct TopicRow: View {
    let summary: TopicSummary

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(summary.topic.title)
                    .foregroundStyle(.primary)
                Text(summary.sampleNames.joined(separator: "・"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text("\(summary.count)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.tint)
                .monospacedDigit()
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(.tint.opacity(0.15), in: .capsule)
        }
        .contentShape(.rect)
    }
}
