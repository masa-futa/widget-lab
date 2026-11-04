import SwiftUI

nonisolated extension CatalogEntry {
    static let uiApplicationDelegateAdaptor = CatalogEntry(
        id: "UIApplicationDelegateAdaptor",
        kind: .propertyWrapper,
        topic: .appOrganization,
        summary: "SwiftUI のアプリに、UIKit のアプリのデリゲート（UIApplicationDelegate）を作って結び付けるプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/uiapplicationdelegateadaptor")!,
        noteReason: "アプリの入口（@main の App）に書くもの。デリゲートはアプリが起動するときに 1 回だけ作られるので、アプリの画面の中では試せない",
        properties: [
            .wrapper(
                "UIApplicationDelegateAdaptor",
                summary: "外すと、AppDelegate が作られず、起動のときの準備（通知の登録など）が呼ばれない")
        ],
        code: CodeTemplate(
            call: "UIApplicationDelegateAdaptor",
            wrapper: WrapperCode(
                withWrapper: [
                    "@main",
                    "struct MemoApp: App {",
                    "    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate",
                    "",
                    "    var body: some Scene {",
                    "        WindowGroup { ContentView() }",
                    "    }",
                    "}",
                    "",
                    "final class AppDelegate: NSObject, UIApplicationDelegate {",
                    "    func application(",
                    "        _ application: UIApplication,",
                    "        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil",
                    "    ) -> Bool {",
                    "        // 起動のときの準備（通知の登録など）",
                    "        return true",
                    "    }",
                    "}",
                ],
                withoutWrapper: [
                    "@main",
                    "struct MemoApp: App {",
                    "    // AppDelegate は作られない",
                    "",
                    "    var body: some Scene {",
                    "        WindowGroup { ContentView() }",
                    "    }",
                    "}",
                ]))
    )
}
