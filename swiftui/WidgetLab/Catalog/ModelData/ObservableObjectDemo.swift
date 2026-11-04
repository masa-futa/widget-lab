import SwiftUI

/// model-data の収録で使う、数を持つ ObservableObject
final class DemoCounter: ObservableObject {
    @Published var count = 0
}

/// model-data の収録で使う、テーマの名前を持つ ObservableObject
final class DemoTheme: ObservableObject {
    @Published var name: String

    init(_ name: String) {
        self.name = name
    }
}

/// 数と +1 のボタン（model-data の見本で共通の見た目）
struct CounterRow: View {
    let title: String
    let count: Int
    let increment: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("\(title): \(count)")
                .monospacedDigit()
            Button("+1", action: increment)
                .buttonStyle(.bordered)
        }
    }
}
