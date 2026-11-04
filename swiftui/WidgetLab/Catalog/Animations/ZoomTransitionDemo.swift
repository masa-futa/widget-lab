import SwiftUI

/// matchedTransitionSource と navigationTransition の見本。写真のボタンを押すと sheet が開く。
/// 開く側に .zoom、ボタンに matchedTransitionSource をかけると、ボタンから大きくなって開く
struct ZoomTransitionDemo: View {
    /// ボタンにかける matchedTransitionSource の見た目。nil なら modifier をかけない
    enum Source {
        case plain, rounded, shadow
    }

    let source: Source?
    /// false なら、開く側に navigationTransition(.zoom) をかけない
    let zooms: Bool
    @Namespace private var namespace
    @State private var isShown = false

    var body: some View {
        Button {
            isShown = true
        } label: {
            Image(systemName: "photo.fill")
                .font(.largeTitle)
                .frame(width: 80, height: 80)
                .background(.yellow, in: .rect(cornerRadius: 16))
        }
        .apply(source) { view, source in
            switch source {
            case .plain: view.matchedTransitionSource(id: "photo", in: namespace)
            case .rounded:
                view.matchedTransitionSource(id: "photo", in: namespace) {
                    $0.background(.yellow).clipShape(.rect(cornerRadius: 16))
                }
            case .shadow: view.matchedTransitionSource(id: "photo", in: namespace) { $0.shadow(radius: 8) }
            }
        }
        .sheet(isPresented: $isShown) {
            Image(systemName: "photo.fill")
                .font(.system(size: 120))
                .apply(zooms ? () : nil) { view, _ in
                    view.navigationTransition(.zoom(sourceID: "photo", in: namespace))
                }
        }
    }
}
