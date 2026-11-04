import AuthenticationServices
import SwiftUI

nonisolated extension CatalogEntry {
    static let signInWithAppleButtonStyle = CatalogEntry(
        id: "signInWithAppleButtonStyle",
        kind: .modifier,
        topic: .viewStyles,
        summary: "「Apple でサインイン」のボタンの色を決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/signinwithapplebuttonstyle(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "signInWithAppleButtonStyle",
                .choice([Choice(".black"), Choice(".white"), Choice(".whiteOutline")], initial: 0), on: true,
                summary: "ボタンの色（OFF なら既定の見た目）")
        ],
        code: CodeTemplate(
            prefix: ["// import AuthenticationServices が要る"], indent: 0, call: "SignInWithAppleButton",
            fixedArguments: [".signIn"], trailing: " { request in\n} onCompletion: { result in\n}",
            suffix: [".frame(width: 260, height: 48)"]),
        build: { v in
            AnyView(
                SignInWithAppleButton(.signIn) { _ in
                } onCompletion: { _ in
                }
                .apply(
                    v.pick(
                        "signInWithAppleButtonStyle", from: [SignInWithAppleButton.Style.black, .white, .whiteOutline])
                ) { $0.signInWithAppleButtonStyle($1) }
                .frame(width: 260, height: 48)
            )
        }
    )
}
