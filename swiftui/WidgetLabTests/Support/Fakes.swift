import SwiftUI
@testable import WidgetLab

struct FakeCatalogRepository: CatalogRepository {
    let entries: [CatalogEntry]

    func allEntries() -> [CatalogEntry] {
        entries
    }
}

final class FakeClipboard: ClipboardClient, @unchecked Sendable {
    private(set) var copied: [String] = []

    func copy(_ text: String) {
        copied.append(text)
    }
}

extension CatalogEntry {
    /// テスト用の収録データ。引数 1 つ（size）と modifier 2 つ（tint・hidden）
    static func fake(id: String = "Sample", kind: EntryKind = .view, topic: Topic = .controlsAndIndicators)
        -> CatalogEntry
    {
        CatalogEntry(
            id: id,
            kind: kind,
            topic: topic,
            summary: "テスト用",
            docURL: URL(string: "https://example.com")!,
            stage: .card,
            properties: [
                .argument("size", .slider(range: 0...10, step: 1, initial: 4), on: true, summary: "大きさ"),
                .modifier("tint", .color(initial: 0), summary: "色"),
                .modifier("hidden", .toggle(initial: true), summary: "隠す"),
            ],
            code: CodeTemplate(call: id),
            build: { _ in AnyView(Text(id)) }
        )
    }
}
