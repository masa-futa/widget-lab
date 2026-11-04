import SwiftUI

/// 文の中を探す（find）見本の入れ物。TextEditor と、検索の帯（findNavigator）を出すボタンを置く。
/// TextEditor にかける modifier を modify で、findNavigator をかけるかを navigator で渡す。
/// 帯は TextEditor に入力の印があるときだけ出るので、文を押してからボタンを押す
struct FindDemo<Editor: View>: View {
    var navigator = true
    @ViewBuilder let modify: (AnyView) -> Editor
    @State private var text = "りんごを 3 つ買う\nみかんを 2 つ買う\nりんごのジャムを作る"
    @State private var shows = false

    var body: some View {
        VStack(spacing: 12) {
            Button("検索の帯を出す") { shows.toggle() }
                .buttonStyle(.bordered)
            modify(AnyView(TextEditor(text: $text)))
                .apply(navigator ? () : nil) { view, _ in view.findNavigator(isPresented: $shows) }
                .frame(height: 120)
        }
        .padding()
    }
}

nonisolated extension CodeTemplate {
    /// FindDemo の TextEditor にかける modifier の収録のコード。modifier は TextEditor の下に並ぶ
    static let inFindDemo = CodeTemplate(
        prefix: ["Button(\"検索の帯を出す\") { shows.toggle() }"], indent: 0, call: "TextEditor",
        fixedArguments: ["text: $memo"], suffix: [".findNavigator(isPresented: $shows)"])
}
