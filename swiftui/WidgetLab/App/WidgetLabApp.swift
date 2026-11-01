import SwiftUI

@main
struct WidgetLabApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(repository: BundledCatalogRepository(), clipboard: SystemClipboard())
        }
    }
}

/// 遷移先
enum Route: Hashable {
    case topic(Topic)
    case entry(String)
}

/// 画面を組み立てて遷移をつなぐ。ホームとトピック画面は押されたことを知らせるだけで、詳細はここで組み立てる
struct RootView: View {
    @State private var catalog: CatalogViewModel
    @State private var path: [Route] = []
    private let clipboard: any ClipboardClient

    init(repository: any CatalogRepository, clipboard: any ClipboardClient) {
        _catalog = State(initialValue: CatalogViewModel(repository: repository))
        self.clipboard = clipboard
    }

    var body: some View {
        NavigationStack(path: $path) {
            HomeScreen(
                viewModel: catalog,
                onTopicTapped: { path.append(.topic($0)) },
                onEntryTapped: { path.append(.entry($0)) }
            )
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .topic(let topic):
                    TopicScreen(
                        topic: topic, entries: catalog.entries(in: topic), onEntryTapped: { path.append(.entry($0)) })
                case .entry(let id):
                    if let entry = catalog.entry(id: id) {
                        DetailHost(entry: entry, clipboard: clipboard)
                    }
                }
            }
        }
    }
}

/// 詳細の ViewModel を、画面が出ているあいだ持つ
private struct DetailHost: View {
    @State private var viewModel: DetailViewModel

    init(entry: CatalogEntry, clipboard: any ClipboardClient) {
        _viewModel = State(initialValue: DetailViewModel(entry: entry, clipboard: clipboard))
    }

    var body: some View {
        DetailScreen(viewModel: viewModel)
    }
}
