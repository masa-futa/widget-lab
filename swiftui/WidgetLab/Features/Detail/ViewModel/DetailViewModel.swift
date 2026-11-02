import Foundation
import Observation

/// 詳細画面の状態（プロパティの値・選んでいるプロパティ・比べる）
@Observable
final class DetailViewModel {
    let entry: CatalogEntry
    /// 選んでいるプロパティの id
    var selectedID: String? {
        didSet { restartDemo() }
    }
    var isComparing = false {
        didSet { restartDemo() }
    }
    /// コードをコピーした直後に true
    private(set) var didCopy = false
    /// 見本の記録（見た目を持たないものの見本が書く）
    let recorder = DetailRecorder()
    /// 見本を作り直すたびに増える。プレビューが見本の id に使う
    private(set) var demoGeneration = 0

    /// 全プロパティの今の値（OFF のものも、ON に戻したときのために値を覚えておく）
    private var values: [String: PropertyValue]
    private var enabled: Set<String>
    private let clipboard: any ClipboardClient

    init(entry: CatalogEntry, clipboard: any ClipboardClient) {
        self.entry = entry
        self.clipboard = clipboard
        values = Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) })
        enabled = entry.initialValues.ids
        // required のプロパティは付けない状態がないので、比べられるものを先に選ぶ
        let properties = entry.properties
        selectedID =
            (properties.first { $0.initiallyOn && !$0.isRequired } ?? properties.first { !$0.isRequired }
            ?? properties.first)?.id
    }

    var selected: PropertySpec? {
        entry.properties.first { $0.id == selectedID }
    }

    func isOn(_ id: String) -> Bool {
        enabled.contains(id)
    }

    func setOn(_ id: String, _ on: Bool) {
        guard entry.properties.first(where: { $0.id == id })?.isRequired != true else { return }
        if on { enabled.insert(id) } else { enabled.remove(id) }
        didCopy = false
        restartDemo()
    }

    func value(_ id: String) -> PropertyValue? {
        values[id]
    }

    /// 値を変える。OFF なら ON にする
    func setValue(_ id: String, _ value: PropertyValue) {
        values[id] = value
        enabled.insert(id)
        didCopy = false
        restartDemo()
    }

    func reset() {
        values = Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) })
        enabled = entry.initialValues.ids
        isComparing = false
        didCopy = false
        restartDemo()
    }

    /// 記録を消して、見本を作り直す（回数を 0 から数え直す）
    private func restartDemo() {
        recorder.clear()
        demoGeneration += 1
    }

    /// プレビューに渡す値（ON のものだけ）
    var current: PropertyValues {
        PropertyValues(values.filter { enabled.contains($0.key) })
    }

    /// 選んでいるプロパティを比べられるか（required は付けない状態がないので比べられない）
    var canCompare: Bool {
        selected.map { !$0.isRequired } ?? false
    }

    /// 比べるときの 2 つ（選んでいるプロパティを付けない／付けた。ほかは同じ）
    var comparison: (without: PropertyValues, with: PropertyValues)? {
        guard isComparing, canCompare, let id = selectedID else { return nil }
        var without = current
        var with = current
        without[id] = nil
        with[id] = values[id]
        return (without, with)
    }

    /// チップに出す今の値（OFF なら "OFF"）
    func valueLabel(_ id: String) -> String {
        guard let spec = entry.properties.first(where: { $0.id == id }), enabled.contains(id), let value = values[id]
        else { return "OFF" }
        if case .text(let s) = value { return s }
        return spec.control.code(for: value)
    }

    /// 最初の値から変えたプロパティ
    var changedIDs: Set<String> {
        let initial = entry.initialValues
        let now = current
        return Set(entry.properties.map(\.id).filter { initial[$0] != now[$0] })
    }

    var codeLines: [CodeLine] {
        CodeGenerator.lines(
            template: entry.code, properties: entry.properties, values: current, changed: changedIDs)
    }

    /// 選んでいるプロパティを書いた行。なければ呼び出しの行
    var selectedLine: CodeLine? {
        let lines = codeLines
        if let id = selectedID, let line = lines.first(where: { $0.propertyIDs.contains(id) }) { return line }
        return lines.first { $0.text.trimmingCharacters(in: .whitespaces).hasPrefix(entry.code.call) }
    }

    var codeText: String {
        codeLines.map(\.text).joined(separator: "\n")
    }

    func copyCode() {
        clipboard.copy(codeText)
        didCopy = true
    }
}
