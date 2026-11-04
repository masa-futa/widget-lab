import SwiftUI

nonisolated extension CatalogEntry {
    static let onContinueUserActivity = CatalogEntry(
        id: "onContinueUserActivity",
        kind: .modifier,
        topic: .systemEvents,
        summary: "アプリが受け取った「していること」（NSUserActivity）を受けて、処理を行う modifier。Handoff や Spotlight から開かれたときに呼ばれる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/oncontinueuseractivity(_:perform:)")!,
        noteReason: "アプリの外から呼ばれる。Handoff で別の端末から続けるときや、Spotlight の結果からアプリを開いたときに効く",
        properties: [
            .modifier(
                "onContinueUserActivity", id: "onContinueUserActivity.type", label: nil,
                .fixed(code: "\"com.example.memo.viewing\""), required: true, summary: "受け取る、していることの種類"),
            .modifier(
                "onContinueUserActivity", id: "onContinueUserActivity.perform", label: "perform",
                .fixed(code: "{ activity in openMemo(titled: activity.title) }"), on: true, summary: "受け取ったときの処理"),
        ],
        code: CodeTemplate(call: "ContentView")
    )
}
