import SwiftUI

nonisolated extension CatalogEntry {
    static let shareLink = CatalogEntry(
        id: "ShareLink",
        kind: .view,
        topic: .controlsAndIndicators,
        summary: "押すと共有のシートを出す View。URL・文字・画像などを、ほかのアプリに渡せる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/sharelink")!,
        stage: .card,
        properties: [
            .argument("title", unlabeled: true, .text(initial: "サイトを共有"), on: true, summary: "名前。省くと「共有」"),
            .argument(
                "item", .fixed(code: "URL(string: \"https://www.apple.com\")!"), required: true, summary: "共有するもの"),
            .argument("subject", .fixed(code: "Text(\"おすすめのサイト\")"), summary: "件名（メールで共有するときなど）"),
            .argument("message", .fixed(code: "Text(\"見てみて\")"), summary: "添える文"),
            .modifier(
                "labelStyle",
                .choice([Choice(".titleAndIcon"), Choice(".iconOnly"), Choice(".titleOnly")], initial: 1),
                summary: "名前とアイコンの出し方"),
        ],
        code: CodeTemplate(call: "ShareLink"),
        build: { v in
            AnyView(
                ShareLinkDemo.link(
                    title: v.text("title"), subject: v["subject"] != nil ? Text("おすすめのサイト") : nil,
                    message: v["message"] != nil ? Text("見てみて") : nil
                )
                .apply(v.pick("labelStyle", from: ShareLinkDemo.LabelKind.allCases)) { ShareLinkDemo.styled($0, $1) }
            )
        }
    )
}

private enum ShareLinkDemo {
    enum LabelKind: CaseIterable {
        case titleAndIcon, iconOnly, titleOnly
    }

    static let url = URL(string: "https://www.apple.com")!

    @ViewBuilder
    static func link(title: String?, subject: Text?, message: Text?) -> some View {
        if let title {
            ShareLink(title, item: url, subject: subject, message: message)
        } else {
            ShareLink(item: url, subject: subject, message: message)
        }
    }

    @ViewBuilder
    static func styled(_ view: some View, _ style: LabelKind) -> some View {
        switch style {
        case .titleAndIcon: view.labelStyle(.titleAndIcon)
        case .iconOnly: view.labelStyle(.iconOnly)
        case .titleOnly: view.labelStyle(.titleOnly)
        }
    }
}
