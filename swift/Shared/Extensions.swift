import SwiftUI

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int          & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b)
    }
}

// MARK: - App Colors
extension Color {
    static let todoPink      = Color(hex: "F6CFDA")
    static let todoPinkLight = Color(hex: "FAE0E9")
    static let todoOrange    = Color(hex: "F0674B")
    static let todoOrangeDark = Color(hex: "D44F35")
    static let todoWhite     = Color(hex: "FFF5F8")
}

// MARK: - App Fonts
// 폰트 파일을 Xcode 프로젝트에 추가 후 Info.plist "Fonts provided by application"에 등록 필요
extension Font {
    static func todoTitle(_ size: CGFloat) -> Font {
        .custom("EF_jejudoldam", size: size)
    }
    static func todoBody(_ size: CGFloat) -> Font {
        .custom("LeeSeoyun", size: size)
    }
}

// MARK: - Dashed Divider
struct DashedDivider: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                var x: CGFloat = 0
                while x < geo.size.width {
                    path.move(to: CGPoint(x: x, y: 1.25))
                    path.addLine(to: CGPoint(x: min(x + 8, geo.size.width), y: 1.25))
                    x += 12
                }
            }
            .stroke(Color.todoOrange.opacity(0.7), lineWidth: 2.5)
        }
    }
}
