import SwiftUI

nonisolated extension CatalogEntry {
    static let progressView = CatalogEntry(
        id: "ProgressView",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "作業の進み具合を示す View。値を渡すと棒、渡さないと回る印になる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/progressview")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "読み込み中"), on: true, summary: "名前"),
            .argument(
                "value", .slider(range: 0...1, step: 0.1, initial: 0.4), on: true, summary: "進み具合（0〜1）。省くと終わりの見えない待ちの印"),
            .modifier(
                "progressViewStyle",
                .choice([Choice(".automatic"), Choice(".linear"), Choice(".circular")], initial: 2),
                summary: "見た目のスタイル"),
            .modifier("tint", .color(initial: 6), summary: "棒の色"),
        ],
        code: CodeTemplate(call: "ProgressView"),
        build: { v in
            AnyView(
                ProgressViewDemo.view(title: v.text("title"), value: v.number("value"))
                    .apply(v.pick("progressViewStyle", from: ProgressViewDemo.Style.allCases)) {
                        ProgressViewDemo.styled($0, $1)
                    }
                    .apply(v.color("tint")) { $0.tint($1) }
                    .frame(width: 240)
            )
        }
    )
}

private enum ProgressViewDemo {
    enum Style: CaseIterable {
        case automatic, linear, circular
    }

    @ViewBuilder
    static func view(title: String?, value: Double?) -> some View {
        switch (title, value) {
        case (let title?, let value?): ProgressView(title, value: value)
        case (let title?, nil): ProgressView(title)
        case (nil, let value?): ProgressView(value: value)
        case (nil, nil): ProgressView()
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: Style) -> some View {
        switch style {
        case .automatic: view.progressViewStyle(.automatic)
        case .linear: view.progressViewStyle(.linear)
        case .circular: view.progressViewStyle(.circular)
        }
    }
}
