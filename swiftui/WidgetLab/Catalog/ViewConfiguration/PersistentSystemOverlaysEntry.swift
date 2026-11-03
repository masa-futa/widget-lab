import SwiftUI

nonisolated extension CatalogEntry {
    static let persistentSystemOverlays = CatalogEntry(
        id: "persistentSystemOverlays",
        kind: .modifier,
        topic: .viewConfiguration,
        summary: "画面に出しっぱなしのシステムの表示（ホームに戻るためのバーなど）を、目立たなくするかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/persistentsystemoverlays(_:)")!,
        stage: .full,
        properties: [
            .modifier(
                "persistentSystemOverlays",
                .choice([Choice(".automatic"), Choice(".visible"), Choice(".hidden")], initial: 2), on: true,
                summary: "出し方。.hidden にすると、しばらく触らないでいると画面のいちばん下のバーが消える")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"画面のいちばん下のバーを見る\""]),
        build: { v in
            AnyView(
                Text("画面のいちばん下のバーを見る")
                    .apply(v.pick("persistentSystemOverlays", from: [Visibility.automatic, .visible, .hidden])) {
                        $0.persistentSystemOverlays($1)
                    }
            )
        }
    )
}
