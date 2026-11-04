import SwiftUI

nonisolated extension CatalogEntry {
    static let timelineView = CatalogEntry(
        id: "TimelineView",
        kind: .view,
        topic: .animations,
        summary: "渡した予定（schedule）の時刻ごとに、中身を描き直す View。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/timelineview")!,
        stage: .card,
        properties: [
            .argument(
                "schedule", unlabeled: true,
                .choice(
                    [
                        Choice(".everyMinute"), Choice(".periodic(from: .now, by: 1)"), Choice(".animation"),
                        Choice(".animation(minimumInterval: 0.5)"),
                    ],
                    initial: 1),
                required: true, summary: "描き直す時刻の予定。.animation は画面の書き換えのたび")
        ],
        code: CodeTemplate(
            call: "TimelineView",
            trailing: " { context in\n"
                + "    let seconds = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)\n"
                + "    VStack {\n        Text(context.date, format: .dateTime.hour().minute().second())\n"
                + "        Capsule()\n            .fill(.blue)\n            .frame(width: 4, height: 40)\n"
                + "            .offset(y: -20)\n            .rotationEffect(.degrees(seconds * 6))\n    }\n}"),
        build: { v in
            AnyView(TimelineViewDemo.view(schedule: v.pick("schedule", from: TimelineViewDemo.Schedule.allCases)))
        }
    )
}

private enum TimelineViewDemo {
    enum Schedule: CaseIterable {
        case everyMinute, periodic, animation, animationHalfSecond
    }

    @ViewBuilder
    static func view(schedule: Schedule?) -> some View {
        switch schedule ?? .periodic {
        case .everyMinute: TimelineView(.everyMinute) { content($0.date) }
        case .periodic: TimelineView(.periodic(from: .now, by: 1)) { content($0.date) }
        case .animation: TimelineView(.animation) { content($0.date) }
        case .animationHalfSecond: TimelineView(.animation(minimumInterval: 0.5)) { content($0.date) }
        }
    }

    private static func content(_ date: Date) -> some View {
        let seconds = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 60)
        return VStack {
            Text(date, format: .dateTime.hour().minute().second())
            Capsule()
                .fill(.blue)
                .frame(width: 4, height: 40)
                .offset(y: -20)
                .rotationEffect(.degrees(seconds * 6))
        }
    }
}
