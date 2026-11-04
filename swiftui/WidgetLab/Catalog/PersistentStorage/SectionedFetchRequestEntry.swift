import SwiftUI

nonisolated extension CatalogEntry {
    static let sectionedFetchRequest = CatalogEntry(
        id: "SectionedFetchRequest",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "Core Data の保存先から取り出したものを、セクションに分けて持つ。保存先が変わると描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/sectionedfetchrequest")!,
        noteReason:
            "Core Data のモデルと保存先（NSPersistentContainer）が要るので、このアプリでは試せない。Core Data を使うアプリで、取り出したものをセクションに分けて一覧にするときに使う",
        properties: [
            .wrapper("SectionedFetchRequest", summary: "外すと @FetchRequest で取り出し、セクションに分けるのを自分で書く")
        ],
        code: CodeTemplate(
            call: "SectionedFetchRequest",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 保存先は親で .environment(\\.managedObjectContext, container.viewContext) で渡す",
                    "@SectionedFetchRequest(sectionIdentifier: \\.color, sortDescriptors: [SortDescriptor(\\.color), SortDescriptor(\\.name)]) private var sections: SectionedFetchResults<String?, Fruit>",
                    "var body: some View {",
                    "    List(sections) { section in Section(section.id ?? \"\") { ForEach(section) { Text($0.name ?? \"\") } } }",
                    "}",
                ],
                withoutWrapper: [
                    "@FetchRequest(sortDescriptors: [SortDescriptor(\\.color), SortDescriptor(\\.name)]) private var fruits: FetchedResults<Fruit>",
                    "var body: some View {",
                    "    // セクションに分けるのは自分で行う",
                    "    List(Dictionary(grouping: fruits, by: \\.color).sorted { ($0.key ?? \"\") < ($1.key ?? \"\") }, id: \\.key) { color, items in",
                    "        Section(color ?? \"\") { ForEach(items) { Text($0.name ?? \"\") } }",
                    "    }",
                    "}",
                ]))
    )
}
