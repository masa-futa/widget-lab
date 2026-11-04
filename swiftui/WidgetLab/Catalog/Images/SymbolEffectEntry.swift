import SwiftUI

nonisolated extension CatalogEntry {
    static let symbolEffect = CatalogEntry(
        id: "symbolEffect",
        kind: .modifier,
        topic: .images,
        summary: "SF Symbols の記号を、記号に合った動き（脈打つ・揺れる・跳ねるなど）で動かす modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/symboleffect(_:options:isactive:)")!,
        stage: .card,
        properties: [
            .modifier(
                "symbolEffect",
                .choice(
                    [
                        Choice(".pulse"), Choice(".variableColor.iterative"), Choice(".breathe"), Choice(".wiggle"),
                        Choice(".bounce"), Choice(".rotate"),
                    ],
                    initial: 1),
                required: true, summary: "動きの種類（options か isActive が ON のときだけ書く）"),
            .modifier(
                "symbolEffect", id: "symbolEffect.options", label: "options",
                .choice([Choice(".repeating"), Choice(".nonRepeating"), Choice(".speed(3)")], initial: 2),
                summary: "繰り返すか・速さ（省くと、動きごとの既定の繰り返し）"),
            .modifier(
                "symbolEffect", id: "symbolEffect.isActive", label: "isActive", .toggle(initial: true), on: true,
                summary: "動かすか（false なら止める）"),
        ],
        code: CodeTemplate(
            prefix: ["Image(systemName: \"speaker.wave.3.fill\")", "    .font(.system(size: 64))"],
            call: ".foregroundStyle", fixedArguments: [".blue"]),
        build: { v in
            AnyView(
                SymbolEffectDemo.styled(
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(.blue),
                    effect: v.pick("symbolEffect", from: SymbolEffectDemo.Effect.allCases) ?? .pulse,
                    options: v.pick(
                        "symbolEffect.options", from: [SymbolEffectOptions.repeating, .nonRepeating, .speed(3)]),
                    isActive: v.flag("symbolEffect.isActive"))
            )
        }
    )
}

private enum SymbolEffectDemo {
    enum Effect: CaseIterable {
        case pulse, variableColor, breathe, wiggle, bounce, rotate
    }

    /// effect は required なので、options と isActive がどちらも OFF なら modifier をかけない（コードもその行を書かない）
    @ViewBuilder
    static func styled(_ view: some View, effect: Effect, options: SymbolEffectOptions?, isActive: Bool?)
        -> some View
    {
        if options == nil && isActive == nil {
            view
        } else {
            effected(view, effect: effect, options: options ?? .default, isActive: isActive ?? true)
        }
    }

    @ViewBuilder
    private static func effected(_ view: some View, effect: Effect, options: SymbolEffectOptions, isActive: Bool)
        -> some View
    {
        switch effect {
        case .pulse: view.symbolEffect(.pulse, options: options, isActive: isActive)
        case .variableColor: view.symbolEffect(.variableColor.iterative, options: options, isActive: isActive)
        case .breathe: view.symbolEffect(.breathe, options: options, isActive: isActive)
        case .wiggle: view.symbolEffect(.wiggle, options: options, isActive: isActive)
        case .bounce: view.symbolEffect(.bounce, options: options, isActive: isActive)
        case .rotate: view.symbolEffect(.rotate, options: options, isActive: isActive)
        }
    }
}
