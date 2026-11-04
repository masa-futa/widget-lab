import SwiftUI

/// ドラッグの見本で運ぶ果物。名前を id にし、ドラッグでは名前の文字として渡す
nonisolated struct DragFruit: Identifiable, Hashable, Sendable, Transferable {
    let id: String

    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.id)
    }
}

/// ドラッグの見本で使う果物の並び
nonisolated let dragFruits = ["りんご", "みかん", "ぶどう"].map(DragFruit.init)

/// ドラッグする札
struct DragChip: View {
    let text: String
    var isSelected = false

    var body: some View {
        Text(text)
            .font(.callout)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? AnyShapeStyle(.orange) : AnyShapeStyle(.yellow), in: .capsule)
            .contentShape(.capsule)
    }
}

/// 落とす先の箱。落ちた文字を並べ、上に乗っているあいだは色を変える
struct DropBox: View {
    let items: [String]
    var isTargeted = false

    var body: some View {
        Text(items.isEmpty ? "ここに落とす" : items.joined(separator: "・"))
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding(8)
            .frame(width: 200, height: 72)
            .background(
                isTargeted ? AnyShapeStyle(.tint.opacity(0.25)) : AnyShapeStyle(.background),
                in: .rect(cornerRadius: 12)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.secondary, style: StrokeStyle(lineWidth: 1, dash: [5]))
            }
            .contentShape(.rect(cornerRadius: 12))
    }
}

/// 落ちた NSItemProvider から文字を読み、読めたら add に渡す（onDrop・itemProvider の見本で使う）
func loadTexts(from providers: [NSItemProvider], add: @escaping @MainActor (String) -> Void) {
    for provider in providers {
        _ = provider.loadObject(ofClass: NSString.self) { object, _ in
            guard let text = object as? NSString else { return }
            let string = String(text)
            Task { @MainActor in add(string) }
        }
    }
}

extension Array where Element: Identifiable {
    /// 並べ替えの差分を当てる。動かすものを抜き、行き先の前（または最後）に入れ直す
    mutating func applyReorder(_ difference: ReorderDifference<Element.ID, ReorderableSingleCollectionIdentifier>) {
        let moving = filter { difference.sources.contains($0.id) }
        removeAll { difference.sources.contains($0.id) }
        switch difference.destination.position {
        case .before(let id): insert(contentsOf: moving, at: firstIndex { $0.id == id } ?? endIndex)
        case .end: append(contentsOf: moving)
        }
    }
}
