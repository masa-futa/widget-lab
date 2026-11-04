import SwiftUI

nonisolated extension CatalogEntry {
    static let accessibilityRotorEntry = CatalogEntry(
        id: "accessibilityRotorEntry",
        kind: .modifier,
        topic: .accessibleNavigation,
        summary: "View の要素に、ローターの項目が飛ぶ先の id を付ける modifier。ローターの AccessibilityRotorEntry と、同じ id と namespace で結ぶ。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/accessibilityrotorentry(id:in:)")!,
        stage: .card,
        properties: [
            .modifier(
                "accessibilityRotorEntry", .fixed(code: "id: mail.id, in: namespace"), on: true,
                summary: "飛ぶ先の id と namespace。外すと、ローターの項目はあっても飛ぶ先が見つからない")
        ],
        code: CodeTemplate(
            prefix: ["VStack {", "    ForEach(mails) { mail in"], indent: 8, call: "MailRow",
            fixedArguments: ["mail: mail"],
            closing: [
                "    }", "}", ".accessibilityRotor(\"未読\") {", "    ForEach(unreadMails) { mail in",
                "        AccessibilityRotorEntry(mail.subject, mail.id, in: namespace)", "    }", "}",
            ]),
        build: { v in
            AnyView(RotorEntryDemo(marks: v["accessibilityRotorEntry"] != nil))
        }
    )
}

private struct RotorEntryDemo: View {
    let marks: Bool
    @Namespace private var namespace

    var body: some View {
        A11yDemo(title: "VoiceOver のローター", lines: lines) {
            VStack(alignment: .leading, spacing: 6) {
                ForEach(DemoMail.samples) { mail in
                    DemoMailRow(mail: mail)
                        .apply(marks ? () : nil) { view, _ in
                            view.accessibilityRotorEntry(id: mail.id, in: namespace)
                        }
                }
            }
            .accessibilityRotor("未読") {
                ForEach(DemoMail.samples.filter(\.isUnread)) { mail in
                    AccessibilityRotorEntry(mail.subject, mail.id, in: namespace)
                }
            }
        }
    }

    private var lines: [String] {
        marks
            ? ["「未読」を選び、上下にスワイプ: 会議の件 → 請求書", "（その行へ VoiceOver のカーソルが移る）"]
            : ["「未読」はあるが、飛ぶ先の行が決まらない"]
    }
}
