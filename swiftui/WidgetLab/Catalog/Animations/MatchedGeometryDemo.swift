import SwiftUI

/// matchedGeometryEffect と @Namespace の見本。押した名前の後ろへ、黄色の帯が動いていく。
/// 帯に matchedGeometryEffect（isSource: false）をかけると、選んだ名前の枠に合わせる。かけないと、並び全体の後ろに出る
struct MatchedGeometryDemo: View {
    /// 帯にかける modifier の引数。nil なら帯に modifier をかけない
    struct Matching {
        var properties: MatchedGeometryProperties = .frame
        var anchor: UnitPoint = .center
    }

    /// false なら @Namespace を使わない（名前にも帯にも matchedGeometryEffect をかけない）
    var usesNamespace = true
    let matching: Matching?
    @Namespace private var namespace
    @State private var selected = "りんご"

    var body: some View {
        HStack {
            ForEach(["りんご", "みかん", "ぶどう"], id: \.self) { name in
                Text(name)
                    .padding(8)
                    .apply(usesNamespace ? () : nil) { view, _ in
                        view.matchedGeometryEffect(id: name, in: namespace)
                    }
                    .onTapGesture { withAnimation { selected = name } }
            }
        }
        .background {
            Capsule()
                .fill(.yellow)
                .apply(usesNamespace ? matching : nil) { view, matching in
                    view.matchedGeometryEffect(
                        id: selected, in: namespace, properties: matching.properties, anchor: matching.anchor,
                        isSource: false)
                }
        }
    }
}
