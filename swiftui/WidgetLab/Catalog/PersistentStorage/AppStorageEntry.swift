import SwiftUI

nonisolated extension CatalogEntry {
    static let appStorage = CatalogEntry(
        id: "AppStorage",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "UserDefaults の値を読み書きする。値が変わると描き直し、アプリを閉じても値が残る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/appstorage")!,
        stage: .behavior,
        properties: [
            .wrapper("AppStorage", summary: "外すと @State になり、子を作り直すたびに 0 に戻る")
        ],
        code: CodeTemplate(
            call: "AppStorage",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@AppStorage(\"count\") private var count = 0",
                    "var body: some View {",
                    "    Button(\"count: \\(count)\") { count += 1 }",
                    "}",
                ],
                withoutWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@State private var count = 0  // 子を作り直すと 0 に戻る",
                    "var body: some View {",
                    "    Button(\"count: \\(count)\") { count += 1 }",
                    "}",
                ])),
        build: { v in
            AnyView(AppStorageDemo.Parent(stores: v["AppStorage"] != nil))
        }
    )
}

private enum AppStorageDemo {
    struct Parent: View {
        let stores: Bool
        @State private var generation = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            VStack(spacing: 8) {
                Button("子を作り直す") {
                    generation += 1
                    recorder?.log("子を作り直した")
                }
                .buttonStyle(.bordered)
                Group {
                    if stores {
                        StoringChild()
                    } else {
                        StateChild()
                    }
                }
                .id(generation)
            }
        }
    }

    struct StoringChild: View {
        @AppStorage("widgetLab.demo.appStorage.count") private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした（UserDefaults に保存）")
            }
        }
    }

    struct StateChild: View {
        @State private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした")
            }
        }
    }
}
