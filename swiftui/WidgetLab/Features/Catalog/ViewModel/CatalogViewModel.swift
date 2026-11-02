import Foundation
import Observation

/// ホームの大分類の節 1 つ
struct CategorySection: Identifiable, Equatable {
    let category: TopicCategory
    let topics: [TopicSummary]

    var id: TopicCategory { category }
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

    /// 収録が 1 件以上あるトピックを、大分類ごとに並べる（並びは TopicCategory・Topic の宣言の順）
    var sections: [CategorySection] {
        TopicCategory.allCases.compactMap { category in
            let topics = Topic.allCases.filter { $0.category == category }.compactMap { topic -> TopicSummary? in
                let names = entries(in: topic).map(\.displayName)
                return names.isEmpty
                    ? nil : TopicSummary(topic: topic, count: names.count, sampleNames: Array(names.prefix(3)))
            }
            return topics.isEmpty ? nil : CategorySection(category: category, topics: topics)
        }
    }

    /// 検索中か（前後の空白を除いて、query が空でない）
    var isSearching: Bool {
        !trimmedQuery.isEmpty
    }

    /// 検索の結果。検索中でなければ空。表示の名前（"@State"・".padding"。id を含む）の部分一致で、
    /// 大文字・小文字を区別せず、id の ABC 順
    var results: [CatalogEntry] {
        guard isSearching else { return [] }
        let trimmed = trimmedQuery
        return
            entries
            .filter { $0.displayName.localizedCaseInsensitiveContains(trimmed) }
            .sorted { $0.id.localizedCaseInsensitiveCompare($1.id) == .orderedAscending }
    }

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespaces)
    }

    func entries(in topic: Topic) -> [CatalogEntry] {
        entries.filter { $0.topic == topic }
    }

    func entry(id: String) -> CatalogEntry? {
        entries.first { $0.id == id }
    }
}
