import UIKit

/// クリップボードへの書き込み。テストでは fake に差し替える
protocol ClipboardClient: Sendable {
    func copy(_ text: String)
}

struct SystemClipboard: ClipboardClient {
    func copy(_ text: String) {
        UIPasteboard.general.string = text
    }
}
