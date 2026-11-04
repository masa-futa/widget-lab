import SwiftUI

nonisolated extension CatalogEntry {
    static let scrollClipDisabled = CatalogEntry(
        id: "scrollClipDisabled",
        kind: .modifier,
        topic: .scrollViews,
        summary: "ScrollView が、中身を自分の枠で切り取らないようにする modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/scrollclipdisabled(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "scrollClipDisabled", .toggle(initial: true), on: true, summary: "切り取らない（影と、枠の左右の外が見える）")
        ],
        code: CodeTemplate(
            call: "ScrollView", fixedArguments: [".horizontal"],
            trailing: " {\n    HStack {\n        ForEach(1...6, id: \\.self) { i in\n            Text(\"\\(i)\")\n"
                + "                .frame(width: 80, height: 80)\n"
                + "                .background(.yellow, in: .rect(cornerRadius: 12))\n"
                + "                .shadow(radius: 8)\n        }\n    }\n}",
            suffix: [".padding(.horizontal, 48)"]),
        build: { v in
            AnyView(
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(1...6, id: \.self) { i in
                            Text("\(i)")
                                .frame(width: 80, height: 80)
                                .background(.yellow, in: .rect(cornerRadius: 12))
                                .shadow(radius: 8)
                        }
                    }
                }
                .apply(v.flag("scrollClipDisabled")) { $0.scrollClipDisabled($1) }
                .padding(.horizontal, 48)
            )
        }
    )
}
