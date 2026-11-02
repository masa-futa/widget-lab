import Testing
@testable import WidgetLab

@MainActor
struct CatalogViewModelTests {
    private func makeViewModel() -> CatalogViewModel {
        CatalogViewModel(
            repository: FakeCatalogRepository(entries: [
                .fake(id: "Button", topic: .controlsAndIndicators),
                .fake(id: "Toggle", topic: .controlsAndIndicators),
                .fake(id: "padding", kind: .modifier, topic: .layoutAdjustments),
                .fake(id: "State", kind: .propertyWrapper, topic: .modelData),
            ]))
    }

    @Test func sectionsListOnlyTopicsWithEntriesInDeclarationOrder() {
        let sections = makeViewModel().sections
        #expect(sections.map(\.category) == [.views, .viewLayout, .dataAndStorage])
        #expect(sections[0].topics.map(\.topic) == [.controlsAndIndicators])
        #expect(sections[0].topics[0].count == 2)
        #expect(sections[0].topics[0].sampleNames == ["Button", "Toggle"])
    }

    @Test func searchMatchesPartOfNameIgnoringCaseInAlphabeticalOrder() {
        let viewModel = makeViewModel()
        viewModel.query = "T"
        #expect(viewModel.results.map(\.id) == ["Button", "State", "Toggle"])
        viewModel.query = "PAD"
        #expect(viewModel.results.map(\.id) == ["padding"])
    }

    @Test func searchMatchesDisplayName() {
        let viewModel = makeViewModel()
        viewModel.query = ".pad"
        #expect(viewModel.results.map(\.id) == ["padding"])
        viewModel.query = "@state"
        #expect(viewModel.results.map(\.id) == ["State"])
    }

    @Test func blankQueryIsNotSearchingAndHasNoResults() {
        let viewModel = makeViewModel()
        viewModel.query = "  "
        #expect(!viewModel.isSearching)
        #expect(viewModel.results.isEmpty)
        viewModel.query = " pad "
        #expect(viewModel.isSearching)
        #expect(viewModel.results.map(\.id) == ["padding"])
    }
}
