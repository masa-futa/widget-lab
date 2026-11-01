/// 収録データを読む窓口。UI と ViewModel は Catalog を直接読まず、ここを通す
protocol CatalogRepository: Sendable {
    func allEntries() -> [CatalogEntry]
}

/// アプリに同梱した収録データ（Catalog.all）を返す
struct BundledCatalogRepository: CatalogRepository {
    func allEntries() -> [CatalogEntry] {
        Catalog.all
    }
}
