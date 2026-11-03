import SwiftUI

/// 文字の入力の見本が使う入れ物。入力した値を @State で持ち、その Binding を content に渡す
/// （見本は収録の build で組み立て直されるが、@State は残るので、打った文字は消えない）
struct TextInputDemo<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initial: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        _value = State(initialValue: initial)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
