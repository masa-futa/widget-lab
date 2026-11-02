import SwiftUI

/// プロパティ 1 つの値
nonisolated enum PropertyValue: Equatable, Sendable {
    case number(Double)
    case flag(Bool)
    /// 選択肢の番号
    case choice(Int)
    /// Palette.colors の番号
    case color(Int)
    case text(String)
}

/// ON のプロパティの値。入っていないプロパティは OFF
nonisolated struct PropertyValues: Equatable, Sendable {
    private var storage: [String: PropertyValue]

    init(_ storage: [String: PropertyValue] = [:]) {
        self.storage = storage
    }

    subscript(id: String) -> PropertyValue? {
        get { storage[id] }
        set { storage[id] = newValue }
    }

    var ids: Set<String> { Set(storage.keys) }

    func number(_ id: String) -> Double? {
        if case .number(let n) = storage[id] { n } else { nil }
    }

    func flag(_ id: String) -> Bool? {
        if case .flag(let b) = storage[id] { b } else { nil }
    }

    func text(_ id: String) -> String? {
        if case .text(let s) = storage[id] { s } else { nil }
    }

    func color(_ id: String) -> Color? {
        if case .color(let i) = storage[id] { Palette.colors[i].color } else { nil }
    }

    /// 選択肢の番号に合う値を options から取り出す（options は選択肢と同じ並び）。
    /// options が選択肢より少ないのは収録データの誤りなので、デバッグのときは止める
    func pick<T>(_ id: String, from options: [T]) -> T? {
        guard case .choice(let i) = storage[id] else { return nil }
        guard options.indices.contains(i) else {
            assertionFailure("\(id) の選択肢 \(i) 番に合う値が options（\(options.count) 件）にない")
            return nil
        }
        return options[i]
    }
}

extension View {
    /// value が nil（プロパティが OFF）なら何もしない。ON なら transform をかける
    @ViewBuilder
    func apply<T, Content: View>(_ value: T?, @ViewBuilder _ transform: (Self, T) -> Content) -> some View {
        if let value {
            transform(self, value)
        } else {
            self
        }
    }
}
