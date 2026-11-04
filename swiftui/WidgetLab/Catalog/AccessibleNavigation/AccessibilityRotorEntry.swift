import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRotor = CatalogEntry(
        id: "accessibilityRotor",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "VoiceOver のローターに、自分で決めた項目を足す modifier。選んだ項目で、当てはまる要素だけを順に飛べる。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/accessibilityrotor(_:entries:entrylabel:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRotor",
                .choice(
                    [
                        Choice("未読", code: "\"未読\", entries: unreadMails, entryLabel: \\.subject"),
                        Choice("既読", code: "\"既読\", entries: readMails, entryLabel: \\.subject"),
                    ], initial: 0), on: true,
                summary: "ローターの名前と、飛ぶ先の一覧。一覧の id で、同じ id の行へ飛ぶ")
        ],
        code: CodeTemplate(
            call: "VStack", trailing: " {\n    ForEach(mails) { mail in\n        MailRow(mail: mail)\n    }\n}"),
        build: { v in
            AnyView(RotorDemo(unread: v.pick("accessibilityRotor", from: [true, false])))
        }
    )
}

private struct RotorDemo: View {
    /// nil なら modifier をかけない。true なら未読、false なら既読
    let unread: Bool?

    var body: some View {
        A11yDemo(title: "VoiceOver のローター", lines: [line]) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(DemoMail.samples) { mail in
                    DemoMailRow(mail: mail)
                }
            }
            .apply(unread) { view, unread in
                view.accessibilityRotor(
                    unread ? "未読" : "既読", entries: DemoMail.samples.filter { $0.isUnread == unread },
                    entryLabel: \.subject)
            }
        }
    }

    private var line: String {
        guard let unread else { return "（自分で足した項目なし）" }
        let subjects = DemoMail.samples.filter { $0.isUnread == unread }.map(\.subject)
        return "「\(unread ? "未読" : "既読")」を選び、上下にスワイプ: " + subjects.joined(separator: " → ")
    }
}
