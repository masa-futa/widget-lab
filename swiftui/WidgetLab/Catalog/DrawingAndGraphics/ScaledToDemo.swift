import SwiftUI

/// scaledToFit・scaledToFill の見本の画像。resizable と、ON なら scaledToFit / scaledToFill をかける
enum ScaledToDemo {
    @ViewBuilder
    static func image(resizable: Bool, contentMode: ContentMode?) -> some View {
        let image = Image(systemName: "car.fill")
        if resizable {
            switch contentMode {
            case .fit: image.resizable().scaledToFit()
            case .fill: image.resizable().scaledToFill()
            case nil: image.resizable()
            }
        } else {
            switch contentMode {
            case .fit: image.scaledToFit()
            case .fill: image.scaledToFill()
            case nil: image
            }
        }
    }
}
