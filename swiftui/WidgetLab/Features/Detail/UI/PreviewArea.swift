import SwiftUI

/// プレビュー。比べるときは、左に「付けない」、右に「付けた」を出し、仕切りをドラッグして見比べる
struct PreviewArea: View {
    let viewModel: DetailViewModel
    /// 仕切りの位置（左端 0 〜 右端 1）
    @State private var split: CGFloat = 0.5

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let pair = viewModel.comparison {
                compare(pair.without, pair.with)
            } else {
                preview(viewModel.current)
            }
            if viewModel.selected != nil {
                Toggle("比べる", isOn: Binding(get: { viewModel.isComparing }, set: { viewModel.isComparing = $0 }))
                    .toggleStyle(.button)
                    .padding(12)
                    .accessibilityIdentifier("compare")
            }
        }
        .background(.background.secondary)
        .clipped()
    }

    private func preview(_ values: PropertyValues) -> some View {
        viewModel.entry.build(values)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func compare(_ without: PropertyValues, _ with: PropertyValues) -> some View {
        GeometryReader { geometry in
            let x = geometry.size.width * split
            ZStack(alignment: .topLeading) {
                preview(with)
                preview(without)
                    .background(.background.secondary)
                    .mask(alignment: .leading) { Rectangle().frame(width: x) }
                Rectangle()
                    .fill(.tint)
                    .frame(width: 2)
                    .offset(x: x - 1)
                HStack {
                    Text("付けない")
                    Spacer()
                    Text("付けた")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(8)
            }
            .contentShape(.rect)
            .gesture(
                DragGesture(minimumDistance: 0).onChanged { value in
                    split = min(max(value.location.x / geometry.size.width, 0), 1)
                }
            )
            .accessibilityElement(children: .contain)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment: split = min(split + 0.1, 1)
                case .decrement: split = max(split - 0.1, 0)
                @unknown default: break
                }
            }
        }
    }
}
