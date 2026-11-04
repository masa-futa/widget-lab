import SwiftUI

/// accessibilityFocused と AccessibilityFocusState の見本。ボタンで、VoiceOver のカーソルを合計へ移す
struct AccessibilityFocusDemo: View {
    /// false なら accessibilityFocused をかけない
    let connects: Bool
    @AccessibilityFocusState private var isTotalFocused: Bool

    var body: some View {
        A11yDemo(title: "VoiceOver のカーソル", lines: lines) {
            VStack(spacing: 12) {
                Button("合計へ移る") { isTotalFocused = true }
                    .buttonStyle(.bordered)
                Text("合計: 1,200 円")
                    .font(.title3)
                    .apply(connects ? () : nil) { view, _ in
                        view.accessibilityFocused($isTotalFocused)
                    }
            }
        }
    }

    private var lines: [String] {
        [
            "isTotalFocused: \(isTotalFocused)",
            connects ? "VoiceOver が入っていれば、ボタンでカーソルが合計に移る" : "（つないでいないので、カーソルは動かない）",
        ]
    }
}
