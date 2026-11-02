import SwiftUI

/// 操作できるプロパティ 1 つの定義
nonisolated struct PropertySpec: Identifiable, Sendable {
    enum Placement: Equatable, Sendable {
        /// イニシャライザ（modifier の収録なら、その modifier）の引数。label が nil なら名前なしの引数
        case argument(label: String?)
        /// modifier。label が nil なら名前なしの引数
        case modifier(name: String, label: String?)
        /// プロパティラッパーそのもの（宣言の頭の @State など）。OFF にすると、ラッパーを外した書き方になる
        case wrapper
    }

    let id: String
    let placement: Placement
    let control: PropertyControl
    let initiallyOn: Bool
    /// OFF にできない（Text の文字など、省くとコードが成り立たない引数）
    var isRequired: Bool = false
    /// 一言の説明（日本語）
    let summary: String

    /// チップと編集パネルに出す名前（例: "role"、".tint"）。同じ modifier に複数のプロパティを付けるとき
    /// （id が modifier の名前と違うとき）は、引数のラベルまで出す（例: ".frame(width:)"）
    var displayName: String {
        switch placement {
        case .argument: id
        case .modifier(let name, let label): id == name ? "." + name : ".\(name)(\(label ?? "_"):)"
        case .wrapper: "@" + id
        }
    }

    /// 引数のプロパティ。引数のラベルは id と同じ（unlabeled なら名前なし）。required ならいつも ON
    static func argument(
        _ id: String, unlabeled: Bool = false, _ control: PropertyControl, on: Bool = false, required: Bool = false,
        summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: id, placement: .argument(label: unlabeled ? nil : id), control: control, initiallyOn: on || required,
            isRequired: required, summary: summary)
    }

    /// modifier のプロパティ。id を省くと modifier の名前を id にする。同じ modifier に複数のプロパティを付けるときは
    /// id を分ける（例: "frame.width"・"frame.height"）。コードでは同じ modifier のプロパティを 1 行にまとめる。
    /// required の引数は、OFF にできず、同じ modifier のほかのプロパティが ON のときだけコードに書く
    static func modifier(
        _ name: String, id: String? = nil, label: String? = nil, _ control: PropertyControl, on: Bool = false,
        required: Bool = false, summary: String
    ) -> PropertySpec {
        PropertySpec(
            id: id ?? name, placement: .modifier(name: name, label: label), control: control,
            initiallyOn: on || required, isRequired: required, summary: summary)
    }

    /// プロパティラッパーそのもの。いつも最初は ON。コードは CodeTemplate.wrapper の 2 つの形を使う
    static func wrapper(_ id: String, summary: String) -> PropertySpec {
        PropertySpec(id: id, placement: .wrapper, control: .fixed(code: "@" + id), initiallyOn: true, summary: summary)
    }
}

/// 操作部品の種類。値の型とコードの書き方を持つ
nonisolated enum PropertyControl: Sendable {
    case slider(range: ClosedRange<Double>, step: Double, initial: Double)
    case toggle(initial: Bool)
    case choice([Choice], initial: Int)
    case color(initial: Int)
    case text(initial: String)
    /// 値を変えられない。ON/OFF だけ切り替える
    case fixed(code: String)

    var initialValue: PropertyValue {
        switch self {
        case .slider(_, _, let initial): .number(initial)
        case .toggle(let initial): .flag(initial)
        case .choice(_, let initial): .choice(initial)
        case .color(let initial): .color(initial)
        case .text(let initial): .text(initial)
        case .fixed: .flag(true)
        }
    }

    /// 値を Swift のコードの文字列にする
    func code(for value: PropertyValue) -> String {
        switch (self, value) {
        case (.slider(_, let step, _), .number(let n)):
            Self.decimal(n, digits: Self.fractionDigits(of: step))
        case (.toggle, .flag(let b)):
            b ? "true" : "false"
        case (.choice(let choices, _), .choice(let i)):
            choices[i].code
        case (.color, .color(let i)):
            Palette.colors[i].code
        case (.text, .text(let s)):
            "\"" + s.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"") + "\""
        case (.fixed(let code), _):
            code
        default:
            preconditionFailure("操作部品と値の種類が合わない: \(self) / \(value)")
        }
    }
}

nonisolated private extension PropertyControl {
    /// step の小数の桁数（1 → 0、0.1 → 1、0.25 → 2）
    static func fractionDigits(of step: Double) -> Int {
        var digits = 0
        var scaled = step
        while digits < 6, (scaled - scaled.rounded()).magnitude > 1e-9 {
            digits += 1
            scaled *= 10
        }
        return digits
    }

    /// digits 桁までの小数で書き、末尾の 0 は省く（0.50 → "0.5"、2.0 → "2"）
    static func decimal(_ n: Double, digits: Int) -> String {
        var text = String(format: "%.\(digits)f", n)
        if text.contains(".") {
            while text.hasSuffix("0") { text.removeLast() }
            if text.hasSuffix(".") { text.removeLast() }
        }
        return text == "-0" ? "0" : text
    }
}

/// 選択肢 1 つ。表示の名前とコードの文字列の組
nonisolated struct Choice: Sendable {
    let label: String
    let code: String

    init(_ label: String, code: String) {
        self.label = label
        self.code = code
    }

    /// 表示の名前とコードが同じもの（例: ".bordered"）
    init(_ code: String) {
        self.init(code, code: code)
    }
}

/// 色の操作部品で選べる色
nonisolated enum Palette {
    struct Entry: Sendable {
        let name: String
        let code: String
        let color: Color
    }

    static let colors: [Entry] = [
        Entry(name: "red", code: ".red", color: .red),
        Entry(name: "orange", code: ".orange", color: .orange),
        Entry(name: "yellow", code: ".yellow", color: .yellow),
        Entry(name: "green", code: ".green", color: .green),
        Entry(name: "blue", code: ".blue", color: .blue),
        Entry(name: "purple", code: ".purple", color: .purple),
        Entry(name: "pink", code: ".pink", color: .pink),
        Entry(name: "gray", code: ".gray", color: .gray),
    ]
}
