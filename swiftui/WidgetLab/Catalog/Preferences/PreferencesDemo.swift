import SwiftUI

/// preferences の収録で使う、子が親に知らせる題名。兄弟の値は後のものを使う
nonisolated struct DemoTitleKey: PreferenceKey {
    static let defaultValue = ""

    static func reduce(value: inout String, nextValue: () -> String) {
        value = nextValue()
    }
}

/// preferences の収録で使う、印を付ける子の枠。兄弟の値は先のものを使う
nonisolated struct DemoBoundsKey: PreferenceKey {
    static var defaultValue: Anchor<CGRect>? { nil }

    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {
        value = value ?? nextValue()
    }
}

/// preferences の収録で使う、子の枠をすべて集めたもの
nonisolated struct DemoAllBoundsKey: PreferenceKey {
    static var defaultValue: [Anchor<CGRect>] { [] }

    static func reduce(value: inout [Anchor<CGRect>], nextValue: () -> [Anchor<CGRect>]) {
        value += nextValue()
    }
}

/// 子の枠（anchor）の位置に描く印。塗る（背景向け）か、枠を描く（重ねる向け）
struct PreferenceMarker: View {
    let anchor: Anchor<CGRect>?
    var fills = false

    var body: some View {
        GeometryReader { proxy in
            if let anchor {
                let rect = proxy[anchor]
                Group {
                    if fills {
                        RoundedRectangle(cornerRadius: 8).fill(.yellow)
                    } else {
                        RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 3)
                    }
                }
                .frame(width: rect.width, height: rect.height)
                .offset(x: rect.minX, y: rect.minY)
            }
        }
    }
}

/// 果物の札を 1 つ（anchor の見本で並べる）
struct FruitTag: View {
    let name: String

    init(_ name: String) {
        self.name = name
    }

    var body: some View {
        Text(name)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
    }
}

/// preferences の見本のコードに書く、キーと印の定義
nonisolated enum PreferenceCode {
    static let titleKey = [
        "",
        "struct TitleKey: PreferenceKey {",
        "    static let defaultValue = \"\"",
        "    static func reduce(value: inout String, nextValue: () -> String) { value = nextValue() }",
        "}",
    ]

    static let boundsKey = [
        "",
        "struct BoundsKey: PreferenceKey {",
        "    static var defaultValue: Anchor<CGRect>? { nil }",
        "    static func reduce(value: inout Anchor<CGRect>?, nextValue: () -> Anchor<CGRect>?) {",
        "        value = value ?? nextValue()",
        "    }",
        "}",
    ]

    /// anchor の位置に印を描く View
    static func marker(fills: Bool) -> [String] {
        [
            "",
            "struct Marker: View {",
            "    let anchor: Anchor<CGRect>?",
            "    var body: some View {",
            "        GeometryReader { proxy in",
            "            if let anchor {",
            "                let rect = proxy[anchor]",
            fills
                ? "                RoundedRectangle(cornerRadius: 8).fill(.yellow)"
                : "                RoundedRectangle(cornerRadius: 8).stroke(.red, lineWidth: 3)",
            "                    .frame(width: rect.width, height: rect.height)",
            "                    .offset(x: rect.minX, y: rect.minY)",
            "            }",
            "        }",
            "    }",
            "}",
        ]
    }
}
