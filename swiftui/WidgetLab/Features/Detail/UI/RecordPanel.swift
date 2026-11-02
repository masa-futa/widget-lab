import SwiftUI

/// 見た目を持たないものの記録の欄。イベントのログを新しい順に出す。見出しの行に accessory（比べるの切り替え）を置く
struct RecordPanel<Accessory: View>: View {
    let recorder: DetailRecorder
    /// 比べているとき、行の頭に側を付ける
    let showsSide: Bool
    @ViewBuilder let accessory: Accessory

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("記録")
                    .font(.caption.bold())
                Spacer()
                accessory
                Button {
                    recorder.clear()
                } label: {
                    Text("消す").frame(minWidth: 44, minHeight: 44)
                }
                .font(.caption)
                .disabled(recorder.lines.isEmpty)
            }
            if recorder.lines.isEmpty {
                Text("見本を触ると、ここに記録が出ます")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer(minLength: 0)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(recorder.lines) { line in
                            Text(showsSide ? "\(line.side.title): \(line.text)" : line.text)
                                .font(.caption)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }
}

extension RecordSide {
    /// 比べるときの見出し
    var title: String {
        switch self {
        case .with: "付けた"
        case .without: "付けない"
        }
    }
}
