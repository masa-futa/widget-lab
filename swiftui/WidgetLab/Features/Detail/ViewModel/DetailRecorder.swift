import Foundation
import Observation

/// 比べるときの側
enum RecordSide: Sendable {
    /// 付けた（比べないときの見本もこちら）
    case with
    /// 付けない
    case without
}

/// body を評価した回数 1 つ
struct BodyCount: Equatable {
    let name: String
    let count: Int
}

/// 記録の 1 行
struct RecordLine: Identifiable, Equatable {
    let id: Int
    let side: RecordSide
    let text: String
}

/// 見本の記録（body を評価した回数とイベントのログ）。詳細画面が持ち、側ごとの窓口を見本に渡す
@Observable
final class DetailRecorder {
    static let maxLines = 20

    /// 新しい順
    private(set) var lines: [RecordLine] = []
    private var counts: [RecordSide: [BodyCount]] = [:]
    @ObservationIgnored private var nextID = 0
    @ObservationIgnored private var sides: [RecordSide: SideRecorder] = [:]

    /// 側ごとの窓口。同じ側には同じものを返す（Environment の値が変わって見本が描き直されないように）
    func recorder(for side: RecordSide) -> any DemoRecorder {
        if let recorder = sides[side] { return recorder }
        let recorder = SideRecorder(side: side, owner: self)
        sides[side] = recorder
        return recorder
    }

    /// 名前ごとの回数（最初に記録した順）
    func bodyCounts(_ side: RecordSide) -> [BodyCount] {
        counts[side] ?? []
    }

    func clear() {
        lines = []
        counts = [:]
    }

    fileprivate func countBody(_ name: String, side: RecordSide) {
        var list = counts[side] ?? []
        if let i = list.firstIndex(where: { $0.name == name }) {
            list[i] = BodyCount(name: name, count: list[i].count + 1)
        } else {
            list.append(BodyCount(name: name, count: 1))
        }
        counts[side] = list
    }

    fileprivate func append(_ text: String, side: RecordSide) {
        lines.insert(RecordLine(id: nextID, side: side, text: text), at: 0)
        nextID += 1
        if lines.count > Self.maxLines {
            lines.removeLast(lines.count - Self.maxLines)
        }
    }
}

/// 側 1 つの窓口。書かれたものに側を付けて DetailRecorder に渡す
private final class SideRecorder: DemoRecorder {
    let side: RecordSide
    /// DetailRecorder が窓口を持つので、こちらは弱く持つ
    weak var owner: DetailRecorder?

    init(side: RecordSide, owner: DetailRecorder) {
        self.side = side
        self.owner = owner
    }

    func bodyEvaluated(_ name: String) {
        owner?.countBody(name, side: side)
    }

    func log(_ event: String) {
        owner?.append(event, side: side)
    }
}
