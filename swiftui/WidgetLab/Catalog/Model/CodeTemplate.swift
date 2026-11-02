import Foundation

/// コードの形。CodeGenerator が、ON のプロパティを埋めてコードにする
///
/// 例: Button("保存", role: .destructive) { } に .tint(.red) が付くとき
///     call: "Button", fixedArguments: ["\"保存\""], trailing: " { }"
nonisolated struct CodeTemplate: Sendable {
    /// 呼び出しより前の行（modifier の収録で、かける相手の見本。例: ["Text(\"見本\")"]）
    var prefix: [String] = []
    /// 呼び出しの名前（例: "Button"、".padding"）
    var call: String
    /// いつも書く引数（ON の引数のプロパティより前に並ぶ）
    var fixedArguments: [String] = []
    /// 呼び出しのあとの末尾のクロージャ（例: " { }"。複数行は "\n" で区切る）
    var trailing: String = ""
    /// いちばん最後に付ける modifier の行（例: [".background(.yellow)"]）
    var suffix: [String] = []
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
        let indent = template.prefix.isEmpty ? "" : "    "
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

        for spec in properties {
            guard case .modifier(let name, let label) = spec.placement, let value = values[spec.id] else { continue }
            let text = "    .\(name)(" + argument(label: label, code: spec.control.code(for: value)) + ")"
            result.append(CodeLine(text: text, propertyIDs: [spec.id], isChanged: changed.contains(spec.id)))
        }
        result += template.suffix.map { CodeLine(text: "    " + $0, propertyIDs: [], isChanged: false) }
        return result
    }

    /// 付けた形では宣言の行に、外した形では付けた形と違う行に、ラッパーの id を付ける
    private static func wrapperLines(_ code: WrapperCode, id: String, isOn: Bool, isChanged: Bool) -> [CodeLine] {
        if isOn {
            return code.withWrapper.map { text in
                let isDeclaration = text.contains("@" + id)
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
