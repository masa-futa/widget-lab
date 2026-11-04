import SwiftUI

nonisolated extension CatalogEntry {
    static let speechAdjustedPitch = CatalogEntry(
        id: "speechAdjustedPitch",
        kind: .modifier,
        topic: .accessibleDescriptions,
        summary: "VoiceOver が文を読む声の高さを上げ下げする modifier。-1（低い）〜 1（高い）で、0 がふつう。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/speechadjustedpitch(_:)")!,
        stage: .card,
        properties: [
            .modifier(
                "speechAdjustedPitch", .slider(range: -1...1, step: 0.5, initial: 0.5), on: true,
                summary: "声の高さ。VoiceOver を入れて、文を読ませて聞く")
        ],
        code: CodeTemplate(call: "Text", fixedArguments: ["\"電池が残りわずかです\""]),
        build: { v in
            AnyView(SpeechPitchDemo(pitch: v.number("speechAdjustedPitch")))
        }
    )
}

private struct SpeechPitchDemo: View {
    /// nil なら modifier をかけない
    let pitch: Double?

    var body: some View {
        A11yDemo(title: "VoiceOver の読み方", lines: [A11yText.element("電池が残りわずかです"), line]) {
            Text("電池が残りわずかです")
                .font(.title3)
                .apply(pitch) { view, pitch in
                    view.speechAdjustedPitch(pitch)
                }
        }
    }

    private var line: String {
        guard let pitch else { return "ふつうの高さの声で読む" }
        return switch pitch {
        case ..<0: "ふつうより低い声で読む（\(pitch.formatted())）"
        case 0: "ふつうの高さの声で読む（0）"
        default: "ふつうより高い声で読む（\(pitch.formatted())）"
        }
    }
}
