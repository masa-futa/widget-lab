import SwiftUI

/// スクロールの端の効果（scrollEdgeEffectStyle・scrollEdgeEffectHidden・safeAreaBar）の見本の中身。
/// 色の違う行を並べる。端の効果は、上のバーの下に入った中身をぼかす
enum EdgeEffectDemo {
    static var rows: some View {
        ForEach(1...30, id: \.self) { i in
            Text("行 \(i)")
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(Color(hue: Double(i % 10) / 10, saturation: 0.5, brightness: 1))
        }
    }

    /// 上に置く見出しのバー
    static var bar: some View {
        Text("見出しのバー")
            .font(.headline)
            .padding(8)
    }
}
