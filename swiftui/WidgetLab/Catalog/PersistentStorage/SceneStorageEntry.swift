import SwiftUI

nonisolated extension CatalogEntry {
    static let sceneStorage = CatalogEntry(
        id: "SceneStorage",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "シーン（窓）ごとに保存する値を読み書きする。システムがシーンを復元するときにも値が戻る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scenestorage")!,
        stage: .behavior,
        properties: [
            .wrapper("SceneStorage", summary: "外すと @State になり、子を作り直すたびに 0 に戻る")
        ],
        code: CodeTemplate(
            call: "SceneStorage",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 親",
                    "Button(\"子を作り直す\") { generation += 1 }",
                    "Child().id(generation)",
                    "",
                    "// 子（Child）",
                    "@SceneStorage(\"count\") private var count = 0",
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
            AnyView(SceneStorageDemo.Parent(stores: v["SceneStorage"] != nil))
        }
    )
}

private enum SceneStorageDemo {
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
        @SceneStorage("widgetLab.demo.sceneStorage.count") private var count = 0
        @Environment(\.demoRecorder) private var recorder

        var body: some View {
            CounterRow(title: "count", count: count) {
                count += 1
                recorder?.log("count を \(count) にした（シーンに保存）")
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
