import SwiftUI
import UIKit

enum ThemeMode: String, CaseIterable, Identifiable, Codable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }

    init(light: UInt32, dark: UInt32) {
        self.init(uiColor: UIColor { traits in
            UIColor(hex: traits.userInterfaceStyle == .dark ? dark : light)
        })
    }

    static let appBackground = Color(light: 0xF2F2F7, dark: 0x000000)
    static let appElevated = Color(light: 0xFFFFFF, dark: 0x1C1C1E)
    static let appCard = Color(light: 0xFFFFFF, dark: 0x1C1C1E)
    static let appCard2 = Color(light: 0xF7F7FA, dark: 0x242426)
    static let appTextPrimary = Color(light: 0x111114, dark: 0xFFFFFF)
    static let appTextSecondary = Color(light: 0x63636B, dark: 0xA7A7AE)
    static let appTextTertiary = Color(light: 0x6A6A72, dark: 0x8E8E96)
    static let appAccent = Color(light: 0x0A7A70, dark: 0x2BD4C4)
    static let appAccent2 = Color(light: 0x0A84FF, dark: 0x409CFF)
    static let appAccentSoft = Color(light: 0xDFF4F1, dark: 0x153B38)
    static let appDanger = Color(hex: 0xFF3B30)
    static let appDangerText = Color(light: 0xD70015, dark: 0xFF6961)
    static let appGold = Color(hex: 0xFFB020)
    static var appSeparator: Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 84 / 255, green: 84 / 255, blue: 88 / 255, alpha: 0.5)
                : UIColor(red: 60 / 255, green: 60 / 255, blue: 67 / 255, alpha: 0.12)
        })
    }

    static var appFill: Color {
        Color(uiColor: UIColor { traits in
            UIColor(white: 0.47, alpha: traits.userInterfaceStyle == .dark ? 0.28 : 0.14)
        })
    }

    static let heroGradient = LinearGradient(
        colors: [Color(hex: 0x12B8A6), Color(hex: 0x0E9EDB), Color(hex: 0x0A84FF)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let buttonGradient = LinearGradient(
        colors: [Color(hex: 0x12B8A6), Color(hex: 0x0A84FF)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let progressGradient = LinearGradient(
        colors: [AppColors.accent, AppColors.accent2],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let benefitGradient = LinearGradient(
        colors: [Color.appAccentSoft, Color(hex: 0x0A84FF).opacity(0.12)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

enum AppColors {
    static let accent = Color.appAccent
    static let accent2 = Color.appAccent2
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

struct AppCardModifier: ViewModifier {
    var padding: CGFloat = 16
    var radius: CGFloat = 22
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.06 : 0), lineWidth: 1)
            }
            .shadow(color: Color.black.opacity(colorScheme == .dark ? 0 : 0.05), radius: 14, x: 0, y: 6)
    }
}

extension View {
    func appCard(padding: CGFloat = 16, radius: CGFloat = 22) -> some View {
        modifier(AppCardModifier(padding: padding, radius: radius))
    }
}
