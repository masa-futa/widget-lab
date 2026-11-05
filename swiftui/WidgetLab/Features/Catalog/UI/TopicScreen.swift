import SwiftUI

/// トピック画面。収録したものの行（見本つき）
struct TopicScreen: View {
    let topic: Topic
    let entries: [CatalogEntry]
    let onEntryTapped: (String) -> Void

    var body: some View {
        List(entries) { entry in
            Button {
                onEntryTapped(entry.id)
            } label: {
                EntryRow(entry: entry)
            }
            .buttonStyle(.navigationRow)
            .listRowInsets(EdgeInsets())
            .accessibilityIdentifier("entry-\(entry.id)")
        }
        .navigationTitle(topic.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// 収録 1 件の行。見本（.card は最初の値で組み立てて縮めたもの、ほかは絵）・名前・種類の印
struct EntryRow: View {
    let entry: CatalogEntry

    var body: some View {
        HStack(spacing: 12) {
            thumbnail
                .frame(width: 80, height: 48)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.displayName)
                    .foregroundStyle(.primary)
                Text(entry.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            KindBadge(kind: entry.kind)
        }
        .contentShape(.rect)
    }
}

private extension EntryRow {
    /// .full・.behavior・.note は行で組み立てない（.note は見本がない。sheet が行から出る・NavigationStack が入れ子になる・記録の窓口がない）
    @ViewBuilder
    var thumbnail: some View {
        switch entry.stage {
        case .card:
            entry.build(entry.initialValues)
                .frame(width: 200, height: 120)
                .scaleEffect(0.4)
                .frame(width: 80, height: 48)
                .clipped()
                .allowsHitTesting(false)
        case .full:
            symbol("rectangle.portrait")
        case .behavior:
            symbol(entry.kind == .propertyWrapper ? "at" : "hand.tap")
        case .note:
            symbol("text.page")
        }
    }

    func symbol(_ name: String) -> some View {
        Image(systemName: name)
            .font(.title2)
            .foregroundStyle(.secondary)
    }
}

private struct KindBadge: View {
    let kind: EntryKind

    var body: some View {
        Text(label)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.quaternary, in: .capsule)
    }

    private var label: String {
        switch kind {
        case .view: "View"
        case .modifier: "modifier"
        case .propertyWrapper: "@"
        case .gesture: "ジェスチャー"
        }
    }
}
