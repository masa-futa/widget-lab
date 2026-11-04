import SwiftUI

nonisolated extension CatalogEntry {
    static let allowsWindowActivationEvents = CatalogEntry(
        id: "allowsWindowActivationEvents",
        kind: .modifier,
        topic: .windows,
        summary: "後ろの窓を押したとき、窓を手前に出すのと同時に、中のジェスチャーも動かすかを決める modifier。",
        docURL: URL(string: "https://developer.apple.com/documentation/swiftui/view/allowswindowactivationevents(_:)")!,
        noteReason: "窓を並べられる iPad と Mac で効く。iPhone では窓がいつも 1 つで手前にあるので、違いが出ない",
        properties: [
            .modifier(
                "allowsWindowActivationEvents", .toggle(initial: true), on: true,
                summary: "true なら、後ろの窓の上でなぞっても、窓が手前に出ると同時にジェスチャーが動く")
        ],
        code: CodeTemplate(
            prefix: ["Circle()", "    .frame(width: 80, height: 80)"], call: ".gesture",
            fixedArguments: ["DragGesture()"])
    )
}
