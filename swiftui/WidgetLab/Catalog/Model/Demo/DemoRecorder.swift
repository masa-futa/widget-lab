import SwiftUI

/// 見本の記録の窓口。見た目を持たないものの見本が、body の評価とイベントを書く。詳細画面が実装する
@MainActor
protocol DemoRecorder: AnyObject, Sendable {
    /// 見本の body が評価された（name は "見本"・"親"・"子" など）
    func bodyEvaluated(_ name: String)
    /// イベントが起きた（"タップを認識（2 回）" など）
    func log(_ event: String)
}

extension EnvironmentValues {
    /// 見本の記録の窓口。nil（一覧の行・テスト）なら記録しない
    @Entry var demoRecorder: (any DemoRecorder)? = nil
}

/// 見本の body の中で `let _ = reportBody(recorder, "見本")` と呼ぶ。body が評価されたことを、body が終わったあとで知らせる
/// （body の中で見張られた値を書くと、描き直しが止まらなくなるため）
@MainActor
func reportBody(_ recorder: (any DemoRecorder)?, _ name: String) {
    guard let recorder else { return }
    Task { recorder.bodyEvaluated(name) }
}
