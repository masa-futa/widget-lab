import SwiftUI

nonisolated extension CatalogEntry {
    static let userActivity = CatalogEntry(
        id: "userActivity",
        kind: .modifier,
        topic: .systemEvents,
        summary: "この画面でしていること（NSUserActivity）を、システムに知らせる modifier。Handoff で別の端末から続けたり、Spotlight に出したりできる。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/useractivity(_:isactive:_:)")!,
        noteReason: "アプリの外で効く。Handoff で Mac や iPad に続きを渡すとき、Spotlight やSiri の提案に出すときに使う",
        properties: [
            .modifier(
                "userActivity", id: "userActivity.type", label: nil, .fixed(code: "\"com.example.memo.viewing\""),
                required: true, summary: "していることの種類（Info.plist の NSUserActivityTypes に書く）"),
            .modifier(
                "userActivity", id: "userActivity.isActive", label: "isActive", .toggle(initial: true), required: true,
                summary: "知らせるか"),
            .modifier(
                "userActivity", id: "userActivity.update", label: nil,
                .fixed(code: "{ activity in activity.title = memo.title }"), on: true,
                summary: "知らせる中身を書く関数"),
        ],
        code: CodeTemplate(call: "MemoScreen", fixedArguments: ["memo: memo"])
    )
}
