import SwiftUI

nonisolated extension CatalogEntry {
    static let geometryGroup = CatalogEntry(
        id: "geometryGroup",
        kind: .modifier,
        topic: .animations,
        summary: "この View の位置と大きさを親の側でまとめて動かし、決まった位置と大きさを中の View へ渡す modifier。中の View が自分のアニメーションを持っていても、親と一緒に動く。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/geometrygroup()")!,
        stage: .card,
        properties: [
            .modifier(
                "geometryGroup", .fixed(code: ""), on: true,
                summary: "外すと、アニメーションを消した星だけが、動きの終わりの場所へいきなり飛ぶ")
        ],
        code: CodeTemplate(
            prefix: ["VStack {"], call: "ZStack", fixedArguments: ["alignment: .topLeading"],
            trailing: " {\n        Color.yellow\n        Image(systemName: \"star.fill\")\n            .padding(8)\n"
                + "            .transaction { $0.animation = nil }\n    }",
            suffix: [".frame(width: isLarge ? 200 : 80, height: isLarge ? 100 : 50)"],
            closing: [
                "    Button(\"大きさを変える\") {", "        withAnimation(.easeInOut(duration: 1.5)) { isLarge.toggle() }",
                "    }", "}",
            ]),
        build: { v in
            AnyView(GeometryGroupDemo(groups: v["geometryGroup"] != nil))
        }
    )
}

private struct GeometryGroupDemo: View {
    let groups: Bool
    @State private var isLarge = false

    var body: some View {
        VStack {
            ZStack(alignment: .topLeading) {
                Color.yellow
                Image(systemName: "star.fill")
                    .padding(8)
                    .transaction { $0.animation = nil }
            }
            .apply(groups ? () : nil) { view, _ in view.geometryGroup() }
            .frame(width: isLarge ? 200 : 80, height: isLarge ? 100 : 50)
            Button("大きさを変える") {
                withAnimation(.easeInOut(duration: 1.5)) { isLarge.toggle() }
            }
            .buttonStyle(.bordered)
        }
        .frame(height: 160)
    }
}
