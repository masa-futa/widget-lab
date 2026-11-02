import Foundation
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

    @Test func reselectingSameValueKeepsRecords() {
        let viewModel = makeViewModel()
        viewModel.recorder.recorder(for: .with).log("タップ")
        let generation = viewModel.demoGeneration
        viewModel.selectedID = viewModel.selectedID
        viewModel.isComparing = false
        #expect(viewModel.recorder.lines.count == 1)
        #expect(viewModel.demoGeneration == generation)
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

    @Test func textEntrySelectsFirstNonRequiredProperty() {
        let viewModel = DetailViewModel(entry: .text, clipboard: clipboard)
        #expect(viewModel.selectedID == "font")
        #expect(viewModel.canCompare)
    }

    @Test func requiredPropertyCannotBeCompared() {
        let viewModel = DetailViewModel(entry: .text, clipboard: clipboard)
        viewModel.selectedID = "content"
        viewModel.isComparing = true
        #expect(viewModel.canCompare == false)
        #expect(viewModel.comparison == nil)
    }

    @Test func nonRequiredPropertyCanBeCompared() {
        let viewModel = makeViewModel()
        viewModel.selectedID = "tint"
        #expect(viewModel.canCompare)
    }

    @Test func editingResetsCopiedState() {
        let viewModel = makeViewModel()
        viewModel.copyCode()
        viewModel.setValue("size", .number(7))
        #expect(viewModel.didCopy == false)
        viewModel.copyCode()
        viewModel.setOn("size", false)
        #expect(viewModel.didCopy == false)
        viewModel.copyCode()
        viewModel.reset()
        #expect(viewModel.didCopy == false)
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

    @Test func noteEntryCannotCompareButWritesCode() {
        let entry = CatalogEntry(
            id: "widgetLabel", kind: .modifier, topic: .appExtensions, summary: "テスト用",
            docURL: URL(string: "https://example.com")!, noteReason: "ウィジェットの中で効く",
            properties: [.argument("label", unlabeled: true, .text(initial: "見出し"), on: true, summary: "")],
            code: CodeTemplate(prefix: ["Gauge(value: 0.5) { }"], call: ".widgetLabel"))
        #expect(entry.stage == .note(reason: "ウィジェットの中で効く"))
        let viewModel = DetailViewModel(entry: entry, clipboard: clipboard)
        #expect(viewModel.canCompare == false)
        viewModel.isComparing = true
        #expect(viewModel.comparison == nil)
        #expect(viewModel.codeText == "Gauge(value: 0.5) { }\n    .widgetLabel(\"見出し\")")
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

    @Test func editingAndResettingClearRecordsAndRestartDemo() {
        let viewModel = makeViewModel()
        viewModel.recorder.recorder(for: .with).log("タップ")
        let start = viewModel.demoGeneration
        viewModel.setValue("size", .number(8))
        #expect(viewModel.recorder.lines.isEmpty)
        #expect(viewModel.demoGeneration > start)

        viewModel.recorder.recorder(for: .without).bodyEvaluated("見本")
        viewModel.setOn("tint", true)
        #expect(viewModel.recorder.bodyCounts(.without).isEmpty)

        viewModel.recorder.recorder(for: .with).log("タップ")
        let beforeReset = viewModel.demoGeneration
        viewModel.reset()
        #expect(viewModel.recorder.lines.isEmpty)
        #expect(viewModel.demoGeneration > beforeReset)
    }

    @Test func togglingCompareOrSelectingClearsRecords() {
        let viewModel = makeViewModel()
        viewModel.recorder.recorder(for: .with).log("タップ")
        viewModel.isComparing = true
        #expect(viewModel.recorder.lines.isEmpty)

        viewModel.recorder.recorder(for: .with).log("タップ")
        viewModel.selectedID = "tint"
        #expect(viewModel.recorder.lines.isEmpty)
    }

    @Test func stateEntrySelectsWrapperAndComparesWithAndWithout() {
        let viewModel = DetailViewModel(entry: .state, clipboard: clipboard)
        #expect(viewModel.selectedID == "State")
        #expect(viewModel.canCompare)
        #expect(viewModel.valueLabel("State") == "ON")
        #expect(viewModel.selectedLine?.text == "@State private var count = 0")
        viewModel.isComparing = true
        #expect(viewModel.comparison?.without["State"] == nil)
        #expect(viewModel.comparison?.with["State"] != nil)
        viewModel.setOn("State", false)
        #expect(viewModel.valueLabel("State") == "OFF")
        #expect(viewModel.selectedLine?.text == "private let box = Box()  // SwiftUI が見張らない参照型")
    }
}
