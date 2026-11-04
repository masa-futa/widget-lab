import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationTransition = CatalogEntry(
        id: "navigationTransition",
        kind: .modifier,
        topic: .animations,
        summary: "この View へ移るとき（push・sheet・fullScreenCover）の遷移の動き方を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationtransition(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "navigationTransition",
                .choice([Choice(".zoom(sourceID: \"photo\", in: namespace)"), Choice(".automatic")], initial: 0),
                on: true, summary: "遷移の動き方。.zoom は matchedTransitionSource の View から大きくなって開く")
        ],
        code: CodeTemplate(
            prefix: [
                "Button { isShown = true } label: {",
                "    Image(systemName: \"photo.fill\")",
                "        .font(.largeTitle)",
                "        .frame(width: 80, height: 80)",
                "        .background(.yellow, in: .rect(cornerRadius: 16))",
                "}",
                ".matchedTransitionSource(id: \"photo\", in: namespace)",
                ".sheet(isPresented: $isShown) {",
                "    Image(systemName: \"photo.fill\")",
            ],
            indent: 8, call: ".font", fixedArguments: [".system(size: 120)"], closing: ["}"]),
        build: { v in
            AnyView(
                ZoomTransitionDemo(
                    source: .plain, zooms: v.pick("navigationTransition", from: [true, false]) ?? false))
        }
    )
}
