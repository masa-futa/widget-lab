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
