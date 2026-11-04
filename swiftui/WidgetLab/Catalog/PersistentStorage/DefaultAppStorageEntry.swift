import SwiftUI

nonisolated extension CatalogEntry {
    static let defaultAppStorage = CatalogEntry(
        id: "defaultAppStorage",
        kind: .modifier,
        topic: .persistentStorage,
        summary: "下の View の @AppStorage が使う保存先（UserDefaults）を決める modifier。付けなければ UserDefaults.standard を使う。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/defaultappstorage(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "defaultAppStorage", .fixed(code: "UserDefaults(suiteName: \"memo\")!"), on: true,
                summary: "@AppStorage の保存先。見本の memo には count の初めの値を 100 にしてあるので、付けると 100 から数える")
        ],
        code: CodeTemplate(
            call: "CountButton",
            closing: [
                "",
                "struct CountButton: View {",
                "    @AppStorage(\"count\") private var count = 0",
                "    var body: some View {",
                "        Button(\"count: \\(count)\") { count += 1 }",
                "    }",
                "}",
            ]),
        build: { v in
            AnyView(
                DefaultAppStorageDemo().apply(v["defaultAppStorage"]) { view, _ in
                    view.defaultAppStorage(DefaultAppStorageDemo.memoStore)
                })
        }
    )
}

private struct DefaultAppStorageDemo: View {
    @AppStorage("widgetLab.demo.defaultAppStorage.count") private var count = 0

    /// 見本の保存先。count の初めの値を 100 にしてある（standard と見分けるため。
    /// register(defaults:) の値はどの保存先からも見えるので、この保存先にだけ書く）
    static let memoStore: UserDefaults = {
        let store = UserDefaults(suiteName: "WidgetLab.demo.memo")!
        let key = "widgetLab.demo.defaultAppStorage.count"
        if store.object(forKey: key) == nil {
            store.set(100, forKey: key)
        }
        return store
    }()

    var body: some View {
        // 比べるの右半分（付けた側）に数が出るよう、右に寄せる
        HStack(spacing: 12) {
            Button("+1") { count += 1 }
                .buttonStyle(.bordered)
            Text("\(count)")
                .font(.largeTitle)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing, 24)
    }
}
