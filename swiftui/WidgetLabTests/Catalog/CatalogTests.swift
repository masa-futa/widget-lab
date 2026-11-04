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

    @Test func everyManifestEntryIsCataloged() {
        let cataloged = Set(Catalog.all.map(\.id))
        let missing = Manifest.entries.map(\.id).filter { !cataloged.contains($0) }
        #expect(missing.isEmpty, "Catalog.all にない Manifest の id（収録の抜け）: \(missing.joined(separator: ", "))")
    }

    @Test func propertyIDsAreUniqueInEachEntry() {
        for entry in Catalog.all {
            let ids = entry.properties.map(\.id)
            #expect(Set(ids).count == ids.count, "\(entry.id) のプロパティの id が重複している")
        }
    }

    @Test func displayNamesAreUniqueInEachEntry() {
        for entry in Catalog.all {
            let names = entry.properties.map(\.displayName)
            #expect(Set(names).count == names.count, "\(entry.id) のチップの名前が重複している")
        }
    }

    @Test func requiredModifierArgumentsHaveNonRequiredSibling() {
        for entry in Catalog.all {
            for spec in entry.properties where spec.isRequired {
                guard case .modifier(let name, _) = spec.placement else { continue }
                let key = spec.line ?? name
                let hasSibling = entry.properties.contains {
                    guard case .modifier(let other, _) = $0.placement else { return false }
                    return ($0.line ?? other) == key && !$0.isRequired
                }
                #expect(hasSibling, "\(entry.id): \(spec.id) は required だが、同じ行の .\(name) に required でない引数がない")
            }
        }
    }

    @Test func eachModifierLineUsesOneModifierName() {
        for entry in Catalog.all {
            var names: [String: String] = [:]
            for spec in entry.properties {
                guard case .modifier(let name, _) = spec.placement else { continue }
                let key = spec.line ?? name
                let first = names[key, default: name]
                #expect(first == name, "\(entry.id): 行 \(key) に .\(first) と .\(name) が混ざっている")
                names[key] = first
            }
        }
    }

    @Test func noteReasonsAreNotEmpty() {
        for entry in Catalog.all {
            guard case .note(let reason) = entry.stage else { continue }
            #expect(!reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, "\(entry.id) の理由が空")
        }
    }

    @Test func wrapperCodeGoesWithWrapperProperty() {
        for entry in Catalog.all {
            let hasWrapperProperty = entry.properties.contains { $0.placement == .wrapper }
            #expect(
                (entry.code.wrapper != nil) == hasWrapperProperty,
                "\(entry.id): CodeTemplate.wrapper と .wrapper のプロパティは、両方あるか両方ないかにする")
        }
    }

    @Test(arguments: Catalog.all.map(\.id))
    func buildsAllCombinations(id: String) throws {
        let entry = try #require(Catalog.all.first { $0.id == id })
        for values in Self.combinations(of: entry) {
            let view = entry.build(values)
            // .full は組み立てだけ（全画面で開くもので、枠の中に描いても確かめられない）。.note は見本がない。
            // .behavior は記録の窓口が nil なら記録しないので、そのまま描ける
            switch entry.stage {
            case .card, .behavior:
                let renderer = ImageRenderer(content: view.frame(width: 320, height: 240))
                #expect(renderer.uiImage != nil, "\(id) を \(values) で描けない")
            case .full, .note:
                break
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
