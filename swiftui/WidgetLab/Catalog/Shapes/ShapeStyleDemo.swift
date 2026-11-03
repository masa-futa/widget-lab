import SwiftUI

/// Shape に、ON の .fill と .stroke だけをかける（Rectangle・Circle・Path の見本で使う）
enum ShapeStyleDemo {
    @ViewBuilder
    static func styled(_ shape: some Shape, fill: Color?, stroke: Color?, lineWidth: Double?) -> some View {
        let hasStroke = stroke != nil || lineWidth != nil
        let width = CGFloat(lineWidth ?? 1)
        if let fill, hasStroke {
            if let stroke {
                shape.fill(fill).stroke(stroke, lineWidth: width)
            } else {
                shape.fill(fill).stroke(.foreground, lineWidth: width)
            }
        } else if let fill {
            shape.fill(fill)
        } else if hasStroke {
            if let stroke {
                shape.stroke(stroke, lineWidth: width)
            } else {
                shape.stroke(lineWidth: width)
            }
        } else {
            shape
        }
    }
}
