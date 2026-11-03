import Foundation

/// コードの形。CodeGenerator が、ON のプロパティを埋めてコードにする
///
/// 例: Button("保存", role: .destructive) { } に .tint(.red) が付くとき
///     call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"
nonisolated struct CodeTemplate: Sendable {
    /// 呼び出しより前の行（modifier の収録で、かける相手の見本。例: ["Text(\"見本\")"]）
    var prefix: [String] = []
    /// 呼び出しの行の字下げの桁数。nil なら、prefix があるとき 4、ないとき 0
    /// （入れ子の中の View にかける modifier の収録で、prefix の最後の行に合わせて決める）
    var indent: Int? = nil
    /// 呼び出しの名前（例: "Button"、".padding"）
    var call: String
    /// いつも書く引数（ON の引数のプロパティより前に並ぶ）
    var fixedArguments: [String] = []
    /// 呼び出しのあとの末尾のクロージャ（例: " { }"。複数行は "\n" で区切る）
    var trailing: String = ""
    /// いちばん最後に付ける modifier の行（例: [".background(.yellow)"]）
    var suffix: [String] = []
    /// suffix のあとに、字下げせずにそのまま書く行（prefix で開いた括弧を閉じる "}" など）
    var closing: [String] = []
    /// プロパティラッパーの収録のコード。あるときは、ここまでの穴埋めの形の代わりに使う
    var wrapper: WrapperCode?
}

/// プロパティラッパーの収録のコード。宣言と body を、付けた形と外した形の 2 通りで持つ
/// （ラッパーを外すと、宣言だけでなく使う側の行も変わるため）
nonisolated struct WrapperCode: Sendable {
    let withWrapper: [String]
    let withoutWrapper: [String]
}

/// コードの 1 行
nonisolated struct CodeLine: Equatable, Sendable {
    let text: String
    /// この行に書いたプロパティの id
    let propertyIDs: [String]
    /// 最初の値から変えたプロパティがこの行にあるか
    let isChanged: Bool
}

nonisolated enum CodeGenerator {
    /// ON のプロパティを埋めて、コードを行ごとに返す
    static func lines(
        template: CodeTemplate, properties: [PropertySpec], values: PropertyValues, changed: Set<String> = []
    ) -> [CodeLine] {
        if let wrapper = template.wrapper, let spec = properties.first(where: { $0.placement == .wrapper }) {
            return wrapperLines(
                wrapper, id: spec.id, isOn: values[spec.id] != nil, isChanged: changed.contains(spec.id))
        }
        let indent = String(repeating: " ", count: template.indent ?? (template.prefix.isEmpty ? 0 : 4))
        // modifier と suffix の字下げ。呼び出しが modifier（"." で始まる）か、末尾のクロージャが複数行（"}" で閉じる）なら
        // 呼び出しと同じ桁、ほかは 1 段深く
        let chain = template.call.hasPrefix(".") || template.trailing.contains("\n") ? indent : indent + "    "
        var result = template.prefix.map { CodeLine(text: $0, propertyIDs: [], isChanged: false) }

        var arguments = template.fixedArguments
        var argumentIDs: [String] = []
        for spec in properties {
            guard case .argument(let label) = spec.placement, let value = values[spec.id] else { continue }
            arguments.append(argument(label: label, code: spec.control.code(for: value)))
            argumentIDs.append(spec.id)
        }
        // 末尾のクロージャだけなら括弧を省く（Button { } など）。.onEnded { } のような続きなら省かない
        let parentheses =
            arguments.isEmpty && template.trailing.hasPrefix(" {") ? "" : "(" + arguments.joined(separator: ", ") + ")"
        let callLines = (indent + template.call + parentheses + template.trailing).components(separatedBy: "\n")
        let callChanged = !changed.isDisjoint(with: argumentIDs)
        result += callLines.enumerated().map { index, text in
            CodeLine(text: text, propertyIDs: index == 0 ? argumentIDs : [], isChanged: index == 0 && callChanged)
        }

        result += modifierLines(properties: properties, values: values, changed: changed, indent: chain)
        result += template.suffix.map { CodeLine(text: chain + $0, propertyIDs: [], isChanged: false) }
        result += template.closing.map { CodeLine(text: $0, propertyIDs: [], isChanged: false) }
        return result
    }

    /// modifier のプロパティを、行の鍵（line、なければ modifier の名前）ごとに 1 行にまとめる
    /// （並びは最初に出てきた順、引数は定義の順）。required でない引数が 1 つも ON でない行は書かない
    private static func modifierLines(
        properties: [PropertySpec], values: PropertyValues, changed: Set<String>, indent: String
    ) -> [CodeLine] {
        var keys: [(key: String, name: String)] = []
        var groups: [String: [(spec: PropertySpec, label: String?)]] = [:]
        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement else { continue }
            let key = spec.line ?? name
            if groups[key] == nil { keys.append((key, name)) }
            groups[key, default: []].append((spec, label))
        }
        return keys.compactMap { key, name in
            let members = groups[key, default: []].compactMap { member in
                values[member.spec.id].map { (spec: member.spec, label: member.label, value: $0) }
            }
            guard members.contains(where: { !$0.spec.isRequired }) else { return nil }
            let arguments = members.map { argument(label: $0.label, code: $0.spec.control.code(for: $0.value)) }
            let ids = members.map(\.spec.id)
            return CodeLine(
                text: indent + ".\(name)(" + arguments.joined(separator: ", ") + ")", propertyIDs: ids,
                isChanged: !changed.isDisjoint(with: ids))
        }
    }

    /// 付けた形では宣言の行に、外した形では付けた形と違う行に、ラッパーの id を付ける
    private static func wrapperLines(_ code: WrapperCode, id: String, isOn: Bool, isChanged: Bool) -> [CodeLine] {
        if isOn {
            return code.withWrapper.map { text in
                // 語として一致させる（@State で @StateObject の行に当たらないように）
                let isDeclaration =
                    text.range(of: "@\(NSRegularExpression.escapedPattern(for: id))\\b", options: .regularExpression)
                    != nil
                return CodeLine(
                    text: text, propertyIDs: isDeclaration ? [id] : [], isChanged: isDeclaration && isChanged)
            }
        }
        return code.withoutWrapper.map { text in
            let differs = !code.withWrapper.contains(text)
            return CodeLine(text: text, propertyIDs: differs ? [id] : [], isChanged: differs && isChanged)
        }
    }

    private static func argument(label: String?, code: String) -> String {
        label.map { "\($0): \(code)" } ?? code
    }
}
