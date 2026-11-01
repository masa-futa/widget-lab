import Foundation
import Observation

/// ホームの大分類の節 1 つ
struct CategorySection: Identifiable, Equatable {
    let category: Category
    let topics: [TopicSummary]

    var id: Category { category }
}

/// ホームのトピックの行 1 つ
struct TopicSummary: Identifiable, Equatable {
    let topic: Topic
    let count: Int
    /// 代表の名前（最初の 3 件）
    let sampleNames: [String]

    var id: Topic { topic }
}

/// ホームとトピック画面の状態
@Observable
final class CatalogViewModel {
    var query = ""
    private let entries: [CatalogEntry]

    init(repository: any CatalogRepository) {
        entries = repository.allEntries()
    }

    /// 収録が 1 件以上あるトピックを、大分類ごとに並べる（並びは Category・Topic の宣言の順）
    var sections: [CategorySection] {
        Category.allCases.compactMap { category in
            let topics = Topic.allCases.filter { $0.category == category }.compactMap { topic -> TopicSummary? in
                let names = entries(in: topic).map(\.displayName)
                return names.isEmpty
                    ? nil : TopicSummary(topic: topic, count: names.count, sampleNames: Array(names.prefix(3)))
            }
            return topics.isEmpty ? nil : CategorySection(category: category, topics: topics)
        }
    }

    /// 検索の結果。query が空なら空。名前の部分一致（大文字・小文字を区別しない）で、id の ABC 順
    var results: [CatalogEntry] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        return
            entries
            .filter { $0.id.localizedCaseInsensitiveContains(trimmed) }
            .sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
    }

    func entries(in topic: Topic) -> [CatalogEntry] {
        entries.filter { $0.topic == topic }
    }

    func entry(id: String) -> CatalogEntry? {
        entries.first { $0.id == id }
    }
}
