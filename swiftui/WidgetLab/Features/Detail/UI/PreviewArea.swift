import SwiftUI

/// プレビュー。比べるときは、左に「付けない」、右に「付けた」を出す
/// 見た目のもの（.card）は重ねて仕切りで見比べ、見た目を持たないもの（.behavior）は左右に並べて下に記録を出す
/// 説明だけのもの（.note）は、見本の代わりに試せない理由を出す
/// 全画面のもの（.full）は、枠に「試す」のボタンだけを出し、押すと見本を全画面で開く（比べるは全画面の中で切り替える）
struct PreviewArea: View {
    let viewModel: DetailViewModel
    /// 仕切りの位置（左端 0 〜 右端 1）
    @State private var split: CGFloat = 0.5

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.entry.stage == .behavior {
                VStack(spacing: 0) {
                    // 見本に重ならないよう、比べるの切り替えは記録の欄の見出しに置く
                    content
                    Divider()
                    RecordPanel(recorder: viewModel.recorder, showsSide: viewModel.comparison != nil) {
                        compareToggle
                    }
                }
                // 見本・描き直しの回数・記録の欄が 280pt に入るよう、文字の大きさの上限を決める
                .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            } else {
                content
                    .overlay(alignment: .bottomTrailing) {
                        compareToggle.padding(12)
                    }
            }
        }
        .background(Self.areaBackground)
        .clipped()
        .fullScreenCover(
            isPresented: Binding(get: { viewModel.isTryingFull }, set: { viewModel.isTryingFull = $0 })
        ) {
            FullTrialScreen(viewModel: viewModel)
        }
    }

    @ViewBuilder
    private var compareToggle: some View {
        if viewModel.canCompare, viewModel.entry.stage != .full {
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
        if case .note(let reason) = viewModel.entry.stage {
            NoteView(reason: reason)
        } else if viewModel.entry.stage == .full {
            FullLauncher { viewModel.isTryingFull = true }
        } else if viewModel.entry.stage == .behavior {
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
        // UI テストが左右の列の中で探せるよう、列を 1 つの入れ物にする
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(side == .with ? "side-with" : "side-without")
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

/// 全画面の収録で、見本の代わりに出す。押すと全画面で開く
private struct FullLauncher: View {
    let onTry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "rectangle.portrait")
                .font(.title)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("画面ぜんたいで動くので、全画面で開いて試します")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("試す", systemImage: "arrow.up.left.and.arrow.down.right", action: onTry)
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("try-full")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// 全画面で試す。上に見本、下に比べるの切り替えと閉じるのボタン
/// （見本に重ねると、TabView のタブバーやナビゲーションバーを隠すので、下に並べる）
private struct FullTrialScreen: View {
    let viewModel: DetailViewModel

    var body: some View {
        VStack(spacing: 0) {
            viewModel.entry.build(viewModel.trialValues)
                .id(viewModel.demoGeneration)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Divider()
            HStack(spacing: 12) {
                if viewModel.canCompare, let selected = viewModel.selected {
                    // どのプロパティを切り替えるかを目で見えるようにする（VoiceOver は Picker のラベルで読める）
                    Text(selected.displayName)
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .accessibilityHidden(true)
                    Picker(
                        selected.displayName,
                        selection: Binding(get: { viewModel.trialShowsWith }, set: { viewModel.trialShowsWith = $0 })
                    ) {
                        Text("付けない").tag(false)
                        Text("付けた").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .accessibilityIdentifier("trial-side")
                }
                Spacer(minLength: 0)
                Button("閉じる") { viewModel.isTryingFull = false }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("close-full")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.bar)
        }
    }
}

/// 説明だけの収録で、見本の代わりに出す。ここで試せない理由
private struct NoteView: View {
    let reason: String

    var body: some View {
        // 収まるなら枠の真ん中に、収まらない（理由が長い・文字が大きい）ならスクロールで読む
        ViewThatFits(in: .vertical) {
            message
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            ScrollView {
                message
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var message: some View {
        VStack(spacing: 8) {
            Image(systemName: "text.page")
                .font(.title)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("ここでは試せません")
                .font(.headline)
            Text(reason)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("note")
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
