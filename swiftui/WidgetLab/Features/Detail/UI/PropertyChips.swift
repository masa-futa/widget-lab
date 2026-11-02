import SwiftUI

/// プロパティのチップの列（名前と今の値）。押すと選ぶ
struct PropertyChips: View {
    @Bindable var viewModel: DetailViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.entry.properties) { spec in
                    Button {
                        viewModel.selectedID = spec.id
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(spec.displayName)
                                .font(.system(.caption, design: .monospaced))
                            Text(viewModel.valueLabel(spec.id))
                                .font(.caption2)
                                .foregroundStyle(viewModel.isOn(spec.id) ? .primary : .secondary)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .frame(minHeight: 44)
                        .background(
                            viewModel.selectedID == spec.id
                                ? AnyShapeStyle(.tint.opacity(0.2)) : AnyShapeStyle(.fill.tertiary),
                            in: .rect(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(viewModel.selectedID == spec.id ? .isSelected : [])
                    .accessibilityIdentifier("chip-\(spec.id)")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
