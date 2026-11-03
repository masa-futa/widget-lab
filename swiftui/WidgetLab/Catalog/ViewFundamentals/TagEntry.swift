import SwiftUI

nonisolated extension CatalogEntry {
    static let tag = CatalogEntry(
        id: "tag",
        kind: .modifier,
        topic: .viewFundamentals,
        summary: "Picker や TabView の選択肢に、見分けるための値を付ける modifier。選んだ値と同じ型の値を付ける。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/tag(_:includeoptional:)")!,
        stage: .card,
        properties: [
            .modifier(
                "tag",
                .choice(
                    [
                        Choice("\"みかん\""),
                        Choice("includeOptional: false", code: "\"みかん\", includeOptional: false"),
                    ],
                    initial: 0),
                on: true,
                summary: "「みかん」の値。付けないか、includeOptional を false にすると、Optional の selection と合わず選べない")
        ],
        code: CodeTemplate(
            prefix: ["Picker(\"果物\", selection: $fruit) {  // fruit は String?", "    Text(\"りんご\").tag(\"りんご\")"],
            call: "Text", fixedArguments: ["\"みかん\""], closing: ["}", ".pickerStyle(.segmented)"]),
        build: { v in
            AnyView(TagDemo(includesOptional: v.pick("tag", from: [true, false])))
        }
    )
}

private struct TagDemo: View {
    /// nil なら「みかん」に tag を付けない
    let includesOptional: Bool?
    @State private var fruit: String? = "りんご"

    var body: some View {
        VStack(spacing: 12) {
            Picker("果物", selection: $fruit) {
                Text("りんご").tag("りんご")
                Text("みかん")
                    .apply(includesOptional) { $0.tag("みかん", includeOptional: $1) }
            }
            .pickerStyle(.segmented)
            Text("選んだ: \(fruit ?? "なし")")
                .font(.caption)
        }
        .frame(width: 240)
    }
}
