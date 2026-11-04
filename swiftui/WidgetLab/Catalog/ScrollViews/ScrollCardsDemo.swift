import SwiftUI

/// 横にスクロールするカードの並び（scrollTargetBehavior・scrollTargetLayout の見本）
struct ScrollCardsDemo: View {
    var body: some View {
        LazyHStack {
            ForEach(1...10, id: \.self) { i in
                Text("\(i)")
                    .frame(width: 160, height: 100)
                    .background(.yellow, in: .rect(cornerRadius: 12))
            }
        }
    }
}
