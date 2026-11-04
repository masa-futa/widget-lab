import SwiftUI

nonisolated extension CatalogEntry {
    static let navigationDocument = CatalogEntry(
        id: "navigationDocument",
        kind: .modifier,
        topic: .navigation,
        summary: "スタックの中の画面が見せている書類（共有できるもの）を決める modifier。iPhone では、題名のメニューの頭に書類の見出しが出る。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/navigationdocument(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "navigationDocument", .fixed(code: "URL(string: \"https://www.apple.com/jp/\")!"), on: true,
                summary: "画面の書類（Transferable）。題名を押すと出るメニューの頭に、見出しと共有が出る")
        ],
        code: CodeTemplate(
            prefix: ["NavigationStack {"], call: "Text", fixedArguments: ["\"題名を押す\""],
            suffix: [
                ".navigationTitle(\"Apple のサイト\")", ".navigationBarTitleDisplayMode(.inline)",
                ".toolbarTitleMenu { Button(\"名前を変える\") { } }",
            ], closing: ["}"]),
        build: { v in
            AnyView(
                NavigationStack {
                    Text("題名を押す")
                        .apply(v["navigationDocument"] != nil ? URL(string: "https://www.apple.com/jp/")! : nil) {
                            $0.navigationDocument($1)
                        }
                        .navigationTitle("Apple のサイト")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbarTitleMenu { Button("名前を変える") {} }
                })
        }
    )
}
