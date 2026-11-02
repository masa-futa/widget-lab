import Testing
@testable import WidgetLab

@MainActor
struct DetailRecorderTests {
    private let recorder = DetailRecorder()

    @Test func countsBodyPerSideAndNameInFirstSeenOrder() {
        let with = recorder.recorder(for: .with)
        with.bodyEvaluated("親")
        with.bodyEvaluated("子")
        with.bodyEvaluated("親")
        recorder.recorder(for: .without).bodyEvaluated("親")
        #expect(recorder.bodyCounts(.with) == [BodyCount(name: "親", count: 2), BodyCount(name: "子", count: 1)])
        #expect(recorder.bodyCounts(.without) == [BodyCount(name: "親", count: 1)])
    }

    @Test func returnsSameRecorderForSameSide() {
        #expect(recorder.recorder(for: .with) === recorder.recorder(for: .with))
        #expect(recorder.recorder(for: .with) !== recorder.recorder(for: .without))
    }

    @Test func keepsNewestLinesFirstWithSideUpToMax() {
        recorder.recorder(for: .without).log("最初")
        for i in 1...DetailRecorder.maxLines {
            recorder.recorder(for: .with).log("\(i)")
        }
        #expect(recorder.lines.count == DetailRecorder.maxLines)
        #expect(recorder.lines.first?.text == "\(DetailRecorder.maxLines)")
        #expect(recorder.lines.first?.side == .with)
        #expect(recorder.lines.last?.text == "1")
        #expect(Set(recorder.lines.map(\.id)).count == recorder.lines.count)
    }

    @Test func clearEmptiesCountsAndLines() {
        recorder.recorder(for: .with).bodyEvaluated("見本")
        recorder.recorder(for: .with).log("タップ")
        recorder.clear()
        #expect(recorder.bodyCounts(.with).isEmpty)
        #expect(recorder.lines.isEmpty)
    }
}
