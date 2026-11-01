import SwiftUI

/// プレビューの出し方
nonisolated enum DemoStage: Sendable {
    /// 詳細のプレビューの枠に収まるもの
    case card
    /// 画面より大きいもの・sheet など。プレビューの「試す」から全画面で開く（Phase 3 で使う）
    case full
    /// 見た目を持たないもの。記録を出す（Phase 2 で使う）
    case behavior
}

/// 収録の 1 件。1 件 = 1 ファイル（Catalog/<トピック>/<名前>Entry.swift）
nonisolated struct CatalogEntry: Identifiable, Sendable {
    /// Manifest と照らすキー（例: "Button"、"padding"、"State"）
    let id: String
    let kind: EntryKind
    let topic: Topic
    /// 公式の要約（日本語）
    let summary: String
    let docURL: URL
    let stage: DemoStage
    let properties: [PropertySpec]
    let code: CodeTemplate
    let build: @MainActor @Sendable (PropertyValues) -> AnyView

    /// 一覧と見出しに出す名前（例: "Button"、".padding"、"@State"）
    var displayName: String {
        switch kind {
        case .view, .gesture: id
        case .modifier: "." + id
        case .propertyWrapper: "@" + id
        }
    }

    /// 最初の値（initiallyOn のプロパティだけ ON）
    var initialValues: PropertyValues {
        PropertyValues(
            Dictionary(uniqueKeysWithValues: properties.filter(\.initiallyOn).map { ($0.id, $0.control.initialValue) })
        )
    }
}
