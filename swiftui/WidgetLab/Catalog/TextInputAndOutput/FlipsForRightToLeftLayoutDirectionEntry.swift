import SwiftUI

nonisolated extension CatalogEntry {
    static let flipsForRightToLeftLayoutDirection = CatalogEntry(
        id: "flipsForRightToLeftLayoutDirection",
        kind: .modifier,
        topic: .textInputAndOutput,
        summary: "右から左に書く言語のとき、View を左右反転して描くかを決める modifier。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/flipsforrighttoleftlayoutdirection(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "flipsForRightToLeftLayoutDirection", .toggle(initial: true), on: true,
                summary: "右から左のとき反転するか（false なら付けないのと同じ）"),
            .modifier(
                "environment",
                .choice(
                    [
                        Choice("右から左", code: "\\.layoutDirection, .rightToLeft"),
                        Choice("左から右", code: "\\.layoutDirection, .leftToRight"),
                    ],
                    initial: 0),
                on: true, summary: "試すための書く向き（アラビア語などは右から左）"),
        ],
        code: CodeTemplate(
            call: "Image", fixedArguments: ["systemName: \"figure.walk\""],
            suffix: [".font(.largeTitle)", ".padding(8)", ".background(.yellow)"]),
        build: { v in
            AnyView(
                Image(systemName: "figure.walk")
                    .apply(v.flag("flipsForRightToLeftLayoutDirection")) {
                        $0.flipsForRightToLeftLayoutDirection($1)
                    }
                    .apply(v.pick("environment", from: [LayoutDirection.rightToLeft, .leftToRight])) {
                        $0.environment(\.layoutDirection, $1)
                    }
                    .font(.largeTitle)
                    .padding(8)
                    .background(.yellow)
            )
        }
    )
}
