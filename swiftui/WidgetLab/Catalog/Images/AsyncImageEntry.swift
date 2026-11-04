import SwiftUI

nonisolated extension CatalogEntry {
    static let asyncImage = CatalogEntry(
        id: "AsyncImage",
        kind: .view,
        topic: .images,
        summary: "URL の画像を裏で読み込み、読み込みの段階（読み込み中・成功・失敗）に合わせて表示する View。見本は、端末の中に書いた画像を読む（アプリがオフラインで動くため）。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/asyncimage")!,
        stage: .card,
        properties: [
            .argument(
                "url",
                .choice(
                    [
                        Choice("読める URL", code: "URL(string: \"https://example.com/photo.png\")"),
                        Choice("読めない URL", code: "URL(string: \"https://example.com/missing.png\")"),
                    ],
                    initial: 0),
                required: true, summary: "読み込む画像の URL"),
            .argument(
                "scale", .slider(range: 1...3, step: 1, initial: 2), on: true,
                summary: "画像の 1 点を何ピクセルとみなすか。大きいほど小さく出る（省くと 1）"),
        ],
        code: CodeTemplate(
            call: "AsyncImage",
            trailing:
                " { phase in\n    if let image = phase.image {\n        image\n    } else if phase.error != nil {\n"
                + "        Image(systemName: \"exclamationmark.triangle\")\n    } else {\n        ProgressView()\n    }\n}"
        ),
        build: { v in
            let url = v.pick(
                "url", from: [AsyncImageDemo.readableURL ?? AsyncImageDemo.missingURL, AsyncImageDemo.missingURL])
            return AnyView(
                AsyncImage(url: url, scale: v.number("scale") ?? 1) { phase in
                    if let image = phase.image {
                        image
                    } else if phase.error != nil {
                        Image(systemName: "exclamationmark.triangle")
                    } else {
                        ProgressView()
                    }
                }
            )
        }
    )
}
