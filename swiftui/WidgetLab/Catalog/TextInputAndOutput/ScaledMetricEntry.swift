import SwiftUI

nonisolated extension CatalogEntry {
    static let scaledMetric = CatalogEntry(
        id: "ScaledMetric",
        kind: .propertyWrapper,
        topic: .textInputAndOutput,
        summary: "数値を、文字の大きさの設定（Dynamic Type）に合わせて大きくしたり小さくしたりするプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/scaledmetric")!,
        stage: .card,
        properties: [
            .wrapper(
                "ScaledMetric",
                summary: "外すと、文字が大きくなってもアイコンは 24 ポイントのまま。見本は使う側で文字の大きさを .accessibility2 にしてある")
        ],
        code: CodeTemplate(
            call: "ScaledMetric",
            wrapper: WrapperCode(
                withWrapper: [
                    "struct Favorite: View {",
                    "    @ScaledMetric private var size = 24.0",
                    "",
                    "    var body: some View {",
                    "        HStack {",
                    "            Image(systemName: \"star.fill\")",
                    "                .resizable()",
                    "                .frame(width: size, height: size)",
                    "                .foregroundStyle(.yellow)",
                    "            Text(\"お気に入り\")",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "// 使う側",
                    "Favorite().dynamicTypeSize(.accessibility2)",
                ],
                withoutWrapper: [
                    "struct Favorite: View {",
                    "    private let size = 24.0",
                    "",
                    "    var body: some View {",
                    "        HStack {",
                    "            Image(systemName: \"star.fill\")",
                    "                .resizable()",
                    "                .frame(width: size, height: size)",
                    "                .foregroundStyle(.yellow)",
                    "            Text(\"お気に入り\")",
                    "        }",
                    "    }",
                    "}",
                    "",
                    "// 使う側",
                    "Favorite().dynamicTypeSize(.accessibility2)",
                ])),
        build: { v in
            AnyView(
                Group {
                    if v["ScaledMetric"] != nil {
                        ScaledMetricDemo.Scaled()
                    } else {
                        ScaledMetricDemo.Fixed()
                    }
                }
                .dynamicTypeSize(.accessibility2)
            )
        }
    )
}

private enum ScaledMetricDemo {
    struct Scaled: View {
        @ScaledMetric private var size = 24.0

        var body: some View {
            Row(size: size)
        }
    }

    struct Fixed: View {
        private let size = 24.0

        var body: some View {
            Row(size: size)
        }
    }

    struct Row: View {
        let size: Double

        var body: some View {
            HStack {
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: size, height: size)
                    .foregroundStyle(.yellow)
                Text("お気に入り")
            }
        }
    }
}
