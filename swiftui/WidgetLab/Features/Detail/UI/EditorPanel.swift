import SwiftUI

/// 選んでいるプロパティを大きく触る編集パネル。付ける／付けないのスイッチと、操作部品
struct EditorPanel: View {
    @Bindable var viewModel: DetailViewModel

    var body: some View {
        if let spec = viewModel.selected {
            Form {
                Section {
                    Toggle(
                        "付ける",
                        isOn: Binding(get: { viewModel.isOn(spec.id) }, set: { viewModel.setOn(spec.id, $0) })
                    )
                    .disabled(spec.isRequired)
                    .accessibilityIdentifier("editor-on")
                    control(spec)
                } header: {
                    Text(spec.displayName).font(.system(.body, design: .monospaced))
                } footer: {
                    Text(spec.summary)
                }
            }
        } else {
            ContentUnavailableView("操作できるプロパティはありません", systemImage: "slider.horizontal.3")
        }
    }

    @ViewBuilder
    private func control(_ spec: PropertySpec) -> some View {
        switch spec.control {
        case .slider(let range, let step, _):
            let value = Binding<Double>(
                get: { if case .number(let n) = viewModel.value(spec.id) { n } else { range.lowerBound } },
                set: { viewModel.setValue(spec.id, .number($0)) })
            LabeledContent {
                Slider(value: value, in: range, step: step)
                    .frame(maxWidth: 220)
            } label: {
                Text(spec.control.code(for: .number(value.wrappedValue))).monospacedDigit()
            }
        case .toggle:
            Toggle(
                "値",
                isOn: Binding(
                    get: { if case .flag(let b) = viewModel.value(spec.id) { b } else { false } },
                    set: { viewModel.setValue(spec.id, .flag($0)) }))
        case .choice(let choices, _):
            Picker(
                "値",
                selection: Binding(
                    get: { if case .choice(let i) = viewModel.value(spec.id) { i } else { 0 } },
                    set: { viewModel.setValue(spec.id, .choice($0)) })
            ) {
                ForEach(choices.indices, id: \.self) { i in
                    Text(choices[i].label).tag(i)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        case .color:
            ColorChoices(
                selected: { if case .color(let i) = viewModel.value(spec.id) { i } else { nil } }(),
                onSelect: { viewModel.setValue(spec.id, .color($0)) })
        case .text:
            TextField(
                "文字",
                text: Binding(
                    get: { if case .text(let s) = viewModel.value(spec.id) { s } else { "" } },
                    set: { viewModel.setValue(spec.id, .text($0)) }))
        case .fixed(let code):
            Text(code).font(.system(.body, design: .monospaced))
        }
    }
}

/// 色の見本を並べて選ぶ
private struct ColorChoices: View {
    let selected: Int?
    let onSelect: (Int) -> Void

    var body: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
            ForEach(Palette.colors.indices, id: \.self) { i in
                let entry = Palette.colors[i]
                Button {
                    onSelect(i)
                } label: {
                    Circle()
                        .fill(entry.color)
                        .frame(width: 44, height: 44)
                        .overlay {
                            if selected == i {
                                Image(systemName: "checkmark").foregroundStyle(.white).bold()
                            }
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(entry.name)
                .accessibilityAddTraits(selected == i ? .isSelected : [])
            }
        }
        .padding(.vertical, 4)
    }
}
