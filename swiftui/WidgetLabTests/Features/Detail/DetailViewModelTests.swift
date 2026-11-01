import Testing
@testable import WidgetLab

@MainActor
struct DetailViewModelTests {
    private let clipboard = FakeClipboard()

    private func makeViewModel() -> DetailViewModel {
        DetailViewModel(entry: .fake(), clipboard: clipboard)
    }

    @Test func startsWithInitiallyOnPropertiesAndSelectsFirstOn() {
        let viewModel = makeViewModel()
        #expect(viewModel.current == PropertyValues(["size": .number(4)]))
        #expect(viewModel.selectedID == "size")
    }

    @Test func turningOffRemovesValueAndTurningOnRestoresLastValue() {
        let viewModel = makeViewModel()
        viewModel.setValue("size", .number(8))
        viewModel.setOn("size", false)
        #expect(viewModel.current["size"] == nil)
        #expect(viewModel.valueLabel("size") == "OFF")
        viewModel.setOn("size", true)
        #expect(viewModel.current["size"] == .number(8))
    }

    @Test func settingValueTurnsPropertyOn() {
        let viewModel = makeViewModel()
        viewModel.setValue("tint", .color(2))
        #expect(viewModel.current["tint"] == .color(2))
        #expect(viewModel.valueLabel("tint") == ".yellow")
    }

    @Test func resetRestoresInitialValuesAndStopsComparing() {
        let viewModel = makeViewModel()
        viewModel.setValue("size", .number(9))
        viewModel.setValue("hidden", .flag(false))
        viewModel.isComparing = true
        viewModel.reset()
        #expect(viewModel.current == PropertyValues(["size": .number(4)]))
        #expect(viewModel.isComparing == false)
    }

    @Test func comparisonDiffersOnlyInSelectedProperty() throws {
        let viewModel = makeViewModel()
        viewModel.setValue("tint", .color(1))
        viewModel.selectedID = "tint"
        viewModel.isComparing = true
        let pair = try #require(viewModel.comparison)
        #expect(pair.without == PropertyValues(["size": .number(4)]))
        #expect(pair.with == PropertyValues(["size": .number(4), "tint": .color(1)]))
    }

    @Test func comparisonIsNilWhenNotComparing() {
        #expect(makeViewModel().comparison == nil)
    }

    @Test func codeLinesMarkChangedAndSelectedLine() {
        let viewModel = makeViewModel()
        viewModel.setValue("tint", .color(0))
        viewModel.selectedID = "tint"
        #expect(viewModel.codeLines.map(\.text) == ["Sample(size: 4)", "    .tint(.red)"])
        #expect(viewModel.codeLines.map(\.isChanged) == [false, true])
        #expect(viewModel.selectedLine?.text == "    .tint(.red)")
    }

    @Test func requiredPropertyCannotBeTurnedOff() {
        let entry = CatalogEntry.text
        let viewModel = DetailViewModel(entry: entry, clipboard: clipboard)
        viewModel.setOn("content", false)
        #expect(viewModel.isOn("content"))
    }

    @Test func copyCodeWritesFullCodeToClipboard() {
        let viewModel = makeViewModel()
        viewModel.copyCode()
        #expect(clipboard.copied == ["Sample(size: 4)"])
        #expect(viewModel.didCopy)
    }
}
