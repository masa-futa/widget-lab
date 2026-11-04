import SwiftUI

/// accessible-navigation の収録で使うメール 1 通
nonisolated struct DemoMail: Identifiable, Sendable {
    let id: Int
    let subject: String
    let isUnread: Bool

    static let samples = [
        DemoMail(id: 1, subject: "会議の件", isUnread: true),
        DemoMail(id: 2, subject: "週末の予定", isUnread: false),
        DemoMail(id: 3, subject: "請求書", isUnread: true),
        DemoMail(id: 4, subject: "お礼", isUnread: false),
    ]
}

/// メールの行。未読は太字と青い点
struct DemoMailRow: View {
    let mail: DemoMail

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(mail.isUnread ? .blue : .clear)
                .frame(width: 8, height: 8)
            Text(mail.subject)
                .fontWeight(mail.isUnread ? .bold : .regular)
            Spacer()
        }
        .frame(width: 200)
    }
}
