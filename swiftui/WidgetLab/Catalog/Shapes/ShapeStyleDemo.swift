import SwiftUI

/// Shape に、ON の .fill と .stroke だけをかける（Rectangle・Circle・Path の見本で使う）。
/// .fill のあとの .stroke は色を省けない（ShapeView の stroke）ので、fill と線を両方かけるのは stroke の色があるときだけ
enum ShapeStyleDemo {
    @ViewBuilder
    static func styled(_ shape: some Shape, fill: Color?, stroke: Color?, lineWidth: Double?) -> some View {
        let hasStroke = stroke != nil || lineWidth != nil
        let width = CGFloat(lineWidth ?? 1)
        if let fill, let stroke {
            shape.fill(fill).stroke(stroke, lineWidth: width)
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
