import Testing
@testable import WidgetLab

struct CodeGeneratorTests {
    private let properties: [PropertySpec] = [
        .argument("role", .choice([Choice(".destructive"), Choice(".cancel")], initial: 0), summary: ""),
        .argument("title", unlabeled: true, .text(initial: "保存"), required: true, summary: ""),
        .modifier("tint", .color(initial: 4), summary: ""),
        .modifier("disabled", .toggle(initial: true), summary: ""),
    ]

    @Test func fillsArgumentsAndModifiersInDefinitionOrder() {
        let template = CodeTemplate(call: "Button", fixedArguments: ["action: {}"])
        let values = PropertyValues([
            "role": .choice(1), "title": .text("OK"), "disabled": .flag(true), "tint": .color(0),
        ])
        let lines = CodeGenerator.lines(template: template, properties: properties, values: values)
        #expect(
            lines.map(\.text) == [
                "Button(action: {}, role: .cancel, \"OK\")",
                "    .tint(.red)",
                "    .disabled(true)",
            ])
        #expect(lines[0].propertyIDs == ["role", "title"])
    }

    @Test func omitsParenthesesWhenOnlyTrailingClosure() {
        let template = CodeTemplate(call: "VStack", trailing: " {\n    Text(\"A\")\n}")
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["VStack {", "    Text(\"A\")", "}"])
    }

    @Test func modifierEntryIndentsCallAfterPrefixAndAddsSuffix() {
        let template = CodeTemplate(prefix: ["Text(\"見本\")"], call: ".padding", suffix: [".background(.yellow)"])
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["Text(\"見本\")", "    .padding()", "    .background(.yellow)"])
    }

    @Test func marksChangedLines() {
        let template = CodeTemplate(call: "Button")
        let values = PropertyValues(["title": .text("OK"), "tint": .color(0)])
        let lines = CodeGenerator.lines(template: template, properties: properties, values: values, changed: ["tint"])
        #expect(lines.map(\.isChanged) == [false, true])
    }

    @Test func formatsValues() {
        #expect(PropertyControl.slider(range: 0...10, step: 1, initial: 0).code(for: .number(8)) == "8")
        #expect(PropertyControl.slider(range: 0...1, step: 0.1, initial: 0).code(for: .number(0.5)) == "0.5")
        #expect(PropertyControl.text(initial: "").code(for: .text("a\"b")) == "\"a\\\"b\"")
        #expect(PropertyControl.fixed(code: ".infinity").code(for: .flag(true)) == ".infinity")
    }

    @Test func keepsParenthesesWhenTrailingIsNotClosure() {
        let template = CodeTemplate(prefix: ["Rectangle()"], call: ".gesture(TapGesture", trailing: ".onEnded { })")
        let lines = CodeGenerator.lines(template: template, properties: [], values: PropertyValues())
        #expect(lines.map(\.text) == ["Rectangle()", "    .gesture(TapGesture().onEnded { })"])
    }

    @Test func groupsArgumentsOfSameModifierIntoOneLine() {
        let frame: [PropertySpec] = [
            .modifier(
                "frame", id: "frame.width", label: "width", .slider(range: 0...200, step: 10, initial: 120),
                summary: ""),
            .modifier("tint", .color(initial: 0), summary: ""),
            .modifier(
                "frame", id: "frame.height", label: "height", .slider(range: 0...200, step: 10, initial: 80),
                summary: ""),
        ]
        #expect(frame.map(\.displayName) == [".frame(width:)", ".tint", ".frame(height:)"])
        let values = PropertyValues(["frame.width": .number(120), "frame.height": .number(80), "tint": .color(0)])
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "Rectangle"), properties: frame, values: values, changed: ["frame.height"])
        #expect(lines.map(\.text) == ["Rectangle()", "    .frame(width: 120, height: 80)", "    .tint(.red)"])
        #expect(lines[1].propertyIDs == ["frame.width", "frame.height"])
        #expect(lines.map(\.isChanged) == [false, true, false])

        let heightOnly = CodeGenerator.lines(
            template: CodeTemplate(call: "Rectangle"), properties: frame,
            values: PropertyValues(["frame.height": .number(80)]))
        #expect(heightOnly.map(\.text) == ["Rectangle()", "    .frame(height: 80)"])
    }

    @Test func requiredModifierArgumentIsWrittenOnlyWithOtherArgumentsOfSameModifier() {
        let shadow: [PropertySpec] = [
            .modifier("shadow", id: "shadow.color", label: "color", .color(initial: 7), summary: ""),
            .modifier(
                "shadow", id: "shadow.radius", label: "radius", .slider(range: 0...20, step: 1, initial: 4),
                required: true, summary: ""),
        ]
        #expect(shadow[1].isRequired && shadow[1].initiallyOn)
        let template = CodeTemplate(call: "Circle")
        let off = CodeGenerator.lines(
            template: template, properties: shadow, values: PropertyValues(["shadow.radius": .number(4)]))
        #expect(off.map(\.text) == ["Circle()"])
        let on = CodeGenerator.lines(
            template: template, properties: shadow,
            values: PropertyValues(["shadow.color": .color(7), "shadow.radius": .number(4)]))
        #expect(on.map(\.text) == ["Circle()", "    .shadow(color: .gray, radius: 4)"])
    }

    @Test func labeledModifierWritesLabel() {
        let spec = PropertySpec.modifier("frame", label: "maxWidth", .fixed(code: ".infinity"), summary: "")
        #expect(spec.id == "frame")
        #expect(spec.displayName == ".frame")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "Text", fixedArguments: ["\"A\""]), properties: [spec],
            values: PropertyValues(["frame": .flag(true)]))
        #expect(lines.map(\.text) == ["Text(\"A\")", "    .frame(maxWidth: .infinity)"])
    }

    private let wrapperCode = WrapperCode(
        withWrapper: ["@State private var count = 0", "", "var body: some View {", "    Text(\"\\(count)\")", "}"],
        withoutWrapper: ["private let box = Box()", "", "var body: some View {", "    Text(\"\\(box.count)\")", "}"])

    @Test func wrapperOnUsesWrappedFormAndPointsAtDeclaration() {
        let spec = PropertySpec.wrapper("State", summary: "")
        #expect(spec.displayName == "@State")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "State", wrapper: wrapperCode), properties: [spec],
            values: PropertyValues(["State": spec.control.initialValue]))
        #expect(lines.map(\.text) == wrapperCode.withWrapper)
        #expect(lines.map(\.propertyIDs) == [["State"], [], [], [], []])
        #expect(lines.allSatisfy { !$0.isChanged })
    }

    @Test func wrapperOffUsesUnwrappedFormAndMarksDifferentLines() {
        let spec = PropertySpec.wrapper("State", summary: "")
        let lines = CodeGenerator.lines(
            template: CodeTemplate(call: "State", wrapper: wrapperCode), properties: [spec], values: PropertyValues(),
            changed: ["State"])
        #expect(lines.map(\.text) == wrapperCode.withoutWrapper)
        #expect(lines.map(\.isChanged) == [true, false, false, true, false])
        #expect(lines.map(\.propertyIDs) == [["State"], [], [], ["State"], []])
    }
}
