import Testing
@testable import WidgetLab

@MainActor
struct CatalogViewModelTests {
    private func makeViewModel() -> CatalogViewModel {
        CatalogViewModel(
            repository: FakeCatalogRepository(entries: [
                .fake(id: "Button", topic: .controlsAndIndicators),
                .fake(id: "Toggle", topic: .controlsAndIndicators),
                .fake(id: "padding", topic: .layoutAdjustments),
            ]))
    }

    @Test func sectionsListOnlyTopicsWithEntriesInDeclarationOrder() {
        let sections = makeViewModel().sections
        #expect(sections.map(\.category) == [.views, .viewLayout])
        #expect(sections[0].topics.map(\.topic) == [.controlsAndIndicators])
        #expect(sections[0].topics[0].count == 2)
        #expect(sections[0].topics[0].sampleNames == ["Button", "Toggle"])
    }

    @Test func searchMatchesPartOfNameIgnoringCaseInAlphabeticalOrder() {
        let viewModel = makeViewModel()
        viewModel.query = "T"
        #expect(viewModel.results.map(\.id) == ["Button", "Toggle"])
        viewModel.query = "PAD"
        #expect(viewModel.results.map(\.id) == ["padding"])
    }

    @Test func emptyQueryHasNoResults() {
        let viewModel = makeViewModel()
        viewModel.query = "  "
        #expect(viewModel.results.isEmpty)
    }
}
