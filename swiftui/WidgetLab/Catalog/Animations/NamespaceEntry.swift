import SwiftUI

nonisolated extension CatalogEntry {
    static let namespace = CatalogEntry(
        id: "Namespace",
        kind: .propertyWrapper,
        topic: .animations,
        summary: "matchedGeometryEffect などで、View の id を探す範囲（名前空間）を作るプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/namespace")!,
        stage: .card,
        properties: [
            .wrapper("Namespace", summary: "外すと名前空間がないので matchedGeometryEffect が書けず、帯は並び全体の後ろに出たまま動かない")
        ],
        code: CodeTemplate(
            call: "Namespace",
            wrapper: WrapperCode(
                withWrapper: [
                    "@Namespace private var namespace",
                    "",
                    "var body: some View {",
                    "    HStack {",
                    "        ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { name in",
                    "            Text(name)",
                    "                .padding(8)",
                    "                .matchedGeometryEffect(id: name, in: namespace)",
                    "                .onTapGesture { withAnimation { selected = name } }",
                    "        }",
                    "    }",
                    "    .background {",
                    "        Capsule()",
                    "            .fill(.yellow)",
                    "            .matchedGeometryEffect(id: selected, in: namespace, isSource: false)",
                    "    }",
                    "}",
                ],
                withoutWrapper: [
                    "var body: some View {",
                    "    HStack {",
                    "        ForEach([\"りんご\", \"みかん\", \"ぶどう\"], id: \\.self) { name in",
                    "            Text(name)",
                    "                .padding(8)",
                    "                .onTapGesture { withAnimation { selected = name } }",
                    "        }",
                    "    }",
                    "    .background {",
                    "        Capsule()",
                    "            .fill(.yellow)",
                    "    }",
                    "}",
                ])),
        build: { v in
            AnyView(
                MatchedGeometryDemo(
                    usesNamespace: v["Namespace"] != nil, matching: MatchedGeometryDemo.Matching()))
        }
    )
}
