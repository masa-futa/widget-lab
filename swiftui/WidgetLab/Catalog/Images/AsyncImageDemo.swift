import SwiftUI

/// AsyncImage の見本が読む画像。アプリはオフラインで動くので、端末の一時フォルダに PNG を書いて、その file URL を渡す
enum AsyncImageDemo {
    /// 読める画像の URL（初めて使うときに書き出す）
    @MainActor static let readableURL: URL? = {
        let url = URL.temporaryDirectory.appending(path: "widget-lab-async-image.png")
        let renderer = ImageRenderer(
            content: Image(systemName: "photo.artframe")
                .font(.system(size: 120))
                .foregroundStyle(.blue)
                .padding(8))
        renderer.scale = 2
        guard let data = renderer.uiImage?.pngData(), (try? data.write(to: url)) != nil else { return nil }
        return url
    }()

    /// 読めない画像の URL（ないファイル）
    static let missingURL = URL.temporaryDirectory.appending(path: "widget-lab-missing.png")
}
