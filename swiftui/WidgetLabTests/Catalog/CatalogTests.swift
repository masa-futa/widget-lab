import SwiftUI
import Testing
@testable import WidgetLab

@MainActor
struct CatalogTests {
    @Test func idsAreUniqueAndListedInManifestWithSameKindAndTopic() {
        let ids = Catalog.all.map(\.id)
        #expect(Set(ids).count == ids.count, "id が重複している")
        let manifest = Dictionary(uniqueKeysWithValues: Manifest.entries.map { ($0.id, $0) })
        for entry in Catalog.all {
            let expected = manifest[entry.id]
            #expect(expected != nil, "\(entry.id) が Manifest にない")
            #expect(expected?.kind == entry.kind, "\(entry.id) の種類が Manifest と違う")
            #expect(expected?.topic == entry.topic, "\(entry.id) のトピックが Manifest と違う")
        }
    }

    @Test func propertyIDsAreUniqueInEachEntry() {
        for entry in Catalog.all {
            let ids = entry.properties.map(\.id)
            #expect(Set(ids).count == ids.count, "\(entry.id) のプロパティの id が重複している")
        }
    }

    @Test(arguments: Catalog.all.map(\.id))
    func buildsAllCombinations(id: String) throws {
        let entry = try #require(Catalog.all.first { $0.id == id })
        for values in Self.combinations(of: entry) {
            let view = entry.build(values)
            // .full・.behavior は組み立てだけ（全画面や記録の窓口がないと、描いても確かめられない）
            if entry.stage == .card {
                let renderer = ImageRenderer(content: view.frame(width: 320, height: 240))
                #expect(renderer.uiImage != nil, "\(id) を \(values) で描けない")
            }
            _ = CodeGenerator.lines(template: entry.code, properties: entry.properties, values: values)
        }
    }

    /// 全部 OFF（required は ON）・全部 ON・選択肢ごと（ほかは最初の値）
    static func combinations(of entry: CatalogEntry) -> [PropertyValues] {
        let required = PropertyValues(
            Dictionary(
                uniqueKeysWithValues: entry.properties.filter(\.isRequired).map { ($0.id, $0.control.initialValue) }))
        let allOn = PropertyValues(
            Dictionary(uniqueKeysWithValues: entry.properties.map { ($0.id, $0.control.initialValue) }))
        var result = [required, allOn]
        for spec in entry.properties {
            guard case .choice(let choices, _) = spec.control else { continue }
            for i in choices.indices {
                var values = entry.initialValues
                values[spec.id] = .choice(i)
                result.append(values)
            }
        }
        return result
    }
}
