import SwiftUI

nonisolated extension CatalogEntry {
    static let onOpenURL = CatalogEntry(
        id: "onOpenURL",
        kind: .modifier,
        topic: .systemEvents,
        summary: "アプリが受け取った URL（独自の scheme・ユニバーサルリンク）を受けて、処理を行う modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/onopenurl(perform:)")!,
        noteReason: "アプリの外から呼ばれる。ほかのアプリ・ウィジェット・Safari から、アプリの URL を開いたときに効く（URL の scheme を Info.plist に登録する）",
        properties: [
            .modifier(
                "onOpenURL", label: "perform", .fixed(code: "{ url in openMemo(at: url) }"), on: true,
                summary: "URL を受け取ったときの処理")
        ],
        code: CodeTemplate(call: "ContentView")
    )
}
