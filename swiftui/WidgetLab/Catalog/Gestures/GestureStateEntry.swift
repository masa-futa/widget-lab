import SwiftUI

nonisolated extension CatalogEntry {
    static let gestureState = CatalogEntry(
        id: "GestureState",
        kind: .propertyWrapper,
        topic: .gestures,
        summary: "ジェスチャーの間だけ値を変え、ジェスチャーが終わると最初の値に戻すプロパティラッパー。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/gesturestate")!,
        stage: .card,
        properties: [
            .wrapper("GestureState", summary: "外して @State にすると、指を離しても値が戻らず、四角は離した所に残る")
        ],
        code: CodeTemplate(
            call: "GestureState",
            wrapper: WrapperCode(
                withWrapper: [
                    "@GestureState private var offset = CGSize.zero",
                    "",
                    "var body: some View {",
                    "    RoundedRectangle(cornerRadius: 12)",
                    "        .offset(offset)",
                    "        .gesture(DragGesture().updating($offset) { value, state, _ in state = value.translation })",
                    "}",
                ],
                withoutWrapper: [
                    "@State private var offset = CGSize.zero",
                    "",
                    "var body: some View {",
                    "    RoundedRectangle(cornerRadius: 12)",
                    "        .offset(offset)",
                    "        .gesture(DragGesture().onChanged { offset = $0.translation })",
                    "}",
                ])),
        build: { v in
            v["GestureState"] != nil
                ? AnyView(GestureStateDemo.WithGestureState()) : AnyView(GestureStateDemo.WithState())
        }
    )
}

private enum GestureStateDemo {
    struct WithGestureState: View {
        @GestureState private var offset = CGSize.zero

        var body: some View {
            GestureTile(text: "引いて離す")
                .offset(offset)
                .gesture(DragGesture().updating($offset) { value, state, _ in state = value.translation })
        }
    }

    struct WithState: View {
        @State private var offset = CGSize.zero

        var body: some View {
            GestureTile(text: "引いて離す")
                .offset(offset)
                .gesture(DragGesture().onChanged { offset = $0.translation })
        }
    }
}
