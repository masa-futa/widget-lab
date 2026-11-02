import SwiftUI

/// プレビュー。比べるときは、左に「付けない」、右に「付けた」を出す
/// 見た目のもの（.card）は重ねて仕切りで見比べ、見た目を持たないもの（.behavior）は左右に並べて下に記録を出す
struct PreviewArea: View {
    let viewModel: DetailViewModel
    /// 仕切りの位置（左端 0 〜 右端 1）
    @State private var split: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.entry.stage == .behavior {
                // 見本に重ならないよう、比べるの切り替えは記録の欄の見出しに置く
                content
                Divider()
                RecordPanel(recorder: viewModel.recorder, showsSide: viewModel.comparison != nil) {
                    compareToggle
                }
                .frame(height: 90)
            } else {
                content
                    .overlay(alignment: .bottomTrailing) {
                        compareToggle.padding(12)
                    }
            }
        }
        .background(Self.areaBackground)
        .clipped()
    }

    @ViewBuilder
    private var compareToggle: some View {
        if viewModel.canCompare {
            Toggle(isOn: Binding(get: { viewModel.isComparing }, set: { viewModel.isComparing = $0 })) {
                // 押せる範囲は label の大きさになるので、ここで 44pt 以上にする
                Text("比べる").frame(minWidth: 44, minHeight: 44)
            }
            .toggleStyle(.button)
            .accessibilityIdentifier("compare")
        }
    }

    @ViewBuilder
    private var content: some View {
        let pair = viewModel.comparison
        if viewModel.entry.stage == .behavior {
            if let pair {
                HStack(spacing: 0) {
                    behavior(pair.without, side: .without, showsSide: true)
                    Divider()
                    behavior(pair.with, side: .with, showsSide: true)
                }
            } else {
                behavior(viewModel.current, side: .with, showsSide: false)
            }
        } else if let pair {
            compare(pair.without, pair.with)
        } else {
            preview(viewModel.current)
        }
    }

    private static let areaBackground = Color(.secondarySystemBackground)

    private func preview(_ values: PropertyValues) -> some View {
        viewModel.entry.build(values)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// 見た目を持たないものの見本 1 つ。側の窓口を渡し、上に body を評価した回数を出す
    private func behavior(_ values: PropertyValues, side: RecordSide, showsSide: Bool) -> some View {
        VStack(spacing: 0) {
            BodyCountLabel(recorder: viewModel.recorder, side: side, showsSide: showsSide)
            viewModel.entry.build(values)
                .environment(\.demoRecorder, viewModel.recorder.recorder(for: side))
                .id(viewModel.demoGeneration)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(8)
    }

    private func compare(_ without: PropertyValues, _ with: PropertyValues) -> some View {
        GeometryReader { geometry in
            let x = geometry.size.width * split
            ZStack(alignment: .topLeading) {
                preview(with)
                preview(without)
                    .background(Self.areaBackground)
                    .mask(alignment: .leading) { Rectangle().frame(width: x) }
                    .accessibilityHidden(true)
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
            .overlay(alignment: .topLeading) {
                // VoiceOver で操作できるよう、仕切りだけを 1 つの要素にする
                Color.clear
                    .frame(width: 44, height: geometry.size.height)
                    .offset(x: x - 22)
                    .accessibilityElement()
                    .accessibilityLabel("仕切り")
                    .accessibilityValue("付けた側 \(Int(((1 - split) * 100).rounded()))%")
                    .accessibilityAdjustableAction { direction in
                        switch direction {
                        case .increment: split = max(split - 0.1, 0)
                        case .decrement: split = min(split + 0.1, 1)
                        @unknown default: break
                        }
                    }
            }
        }
    }
}

/// 側 1 つの、見本の body を評価した回数（例: 「描き直し 4 回」「描き直し 親 4 回・子 4 回」）
private struct BodyCountLabel: View {
    let recorder: DetailRecorder
    let side: RecordSide
    let showsSide: Bool

    var body: some View {
        VStack(spacing: 2) {
            if showsSide {
                Text(side.title)
            }
            Text(countText)
                .monospacedDigit()
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(showsSide ? "\(side.title)側、\(countText)" : countText)
    }

    private var countText: String {
        let counts = recorder.bodyCounts(side)
        guard counts.count > 1 else { return "描き直し \(counts.first?.count ?? 0) 回" }
        return "描き直し " + counts.map { "\($0.name) \($0.count) 回" }.joined(separator: "・")
    }
}
