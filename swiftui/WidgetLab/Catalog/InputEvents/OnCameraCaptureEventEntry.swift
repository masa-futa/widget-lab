import SwiftUI

nonisolated extension CatalogEntry {
    static let onCameraCaptureEvent = CatalogEntry(
        id: "onCameraCaptureEvent",
        kind: .modifier,
        topic: .inputEvents,
        summary: "カメラで撮影している画面で、音量ボタンやカメラコントロールが押されたときに、処理を行う modifier（AVKit）。",
        docURL: URL(
            string: "https://developer.apple.com/documentation/swiftui/view/oncameracaptureevent(isenabled:action:)")!,
        noteReason: "カメラで撮影している（AVCaptureSession が動いている）画面で効く。このアプリには撮影の画面がなく、シミュレータにはカメラもない",
        properties: [
            .argument("isEnabled", .toggle(initial: true), summary: "false にすると、押しても処理を行わない"),
            .argument(
                "action", .fixed(code: "{ event in if event.phase == .ended { takePhoto() } }"), required: true,
                summary: "押されたときの処理（.began・.ended・.cancelled の段階を受け取る）"),
        ],
        code: CodeTemplate(
            prefix: ["// import AVKit が要る", "CameraPreview(session: session)"],
            call: ".onCameraCaptureEvent")
    )
}
