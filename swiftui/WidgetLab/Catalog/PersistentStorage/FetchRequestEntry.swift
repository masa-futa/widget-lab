import SwiftUI

nonisolated extension CatalogEntry {
    static let fetchRequest = CatalogEntry(
        id: "FetchRequest",
        kind: .propertyWrapper,
        topic: .persistentStorage,
        summary: "Core Data の保存先から、条件と並びに合うものを取り出す。保存先が変わると描き直す。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/fetchrequest")!,
        noteReason: "Core Data のモデルと保存先（NSPersistentContainer）が要るので、このアプリでは試せない。Core Data を使うアプリで、保存先から一覧を取り出すときに使う",
        properties: [
            .wrapper("FetchRequest", summary: "外すと、保存先から自分で読み込むことになり、保存先が変わっても描き直さない")
        ],
        code: CodeTemplate(
            call: "FetchRequest",
            wrapper: WrapperCode(
                withWrapper: [
                    "// 保存先は親で .environment(\\.managedObjectContext, container.viewContext) で渡す",
                    "@FetchRequest(sortDescriptors: [SortDescriptor(\\.name)]) private var fruits: FetchedResults<Fruit>",
                    "var body: some View {",
                    "    List(fruits) { Text($0.name ?? \"\") }",
                    "}",
                ],
                withoutWrapper: [
                    "@Environment(\\.managedObjectContext) private var context",
                    "@State private var fruits: [Fruit] = []  // 保存先が変わっても描き直さない",
                    "var body: some View {",
                    "    List(fruits) { Text($0.name ?? \"\") }",
                    "        .task { fruits = (try? context.fetch(Fruit.fetchRequest())) ?? [] }",
                    "}",
                ]))
    )
}
