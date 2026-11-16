import SwiftUI

struct ScreenHeader: View {
    let eyebrow: String
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(eyebrow)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.7)
                .textCase(.uppercase)
                .foregroundStyle(Color.appTextTertiary)
            Text(title)
                .font(.system(size: 30, weight: .heavy))
                .tracking(-1.3)
                .foregroundStyle(Color.appTextPrimary)
                .padding(.top, 4)
            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.top, 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 4)
        .padding(.top, 8)
        .padding(.bottom, 14)
    }
}

struct ProgressTrack: View {
    var progress: Double
    var height: CGFloat = 6

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule().fill(Color.appFill)
                Capsule()
                    .fill(Color.progressGradient)
                    .frame(width: max(0, min(1, progress)) * geometry.size.width)
            }
        }
        .frame(height: height)
        .accessibilityElement()
        .accessibilityValue("\(Int(progress * 100))%")
    }
}

struct SourceChip: View {
    let icon: String
    let text: String
    var action: (() -> Void)? = nil

    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10, weight: .semibold))
                Text(text)
                    .font(.system(size: 10, weight: .semibold))
            }
            .foregroundStyle(Color.appTextSecondary)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Capsule().fill(Color.appFill))
        }
        .buttonStyle(.plain)
        .disabled(action == nil)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 29, height: 29)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.appAccentSoft))
                .padding(.bottom, 8)
            Text(value)
                .font(.system(size: 19, weight: .heavy))
                .tracking(-0.7)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 10.5))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 2)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 13, radius: 20)
    }
}

struct AchievementIcon: View {
    let icon: String
    var size: CGFloat = 38
    var locked: Bool = false

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: size * 0.48, weight: .semibold))
            .foregroundStyle(locked ? Color.appTextTertiary : Color.appAccent)
            .frame(width: size, height: size)
            .background(
                Circle().fill(
                    locked
                        ? AnyShapeStyle(Color.appFill)
                        : AnyShapeStyle(Color.benefitGradient)
                )
            )
    }
}

struct AchievementTile: View {
    let achievement: Achievement
    let unlocked: Bool
    let language: AppLanguage
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                AchievementIcon(icon: achievement.icon, size: 34, locked: !unlocked)
                Text(achievement.title.value(language))
                    .font(.system(size: 8.5, weight: .semibold))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 4)
            .padding(.vertical, 10)
            .appCard(padding: 0, radius: 16)
            .opacity(unlocked ? 1 : 0.45)
        }
        .buttonStyle(.plain)
    }
}

struct SegmentOption: Identifiable {
    let id: String
    let title: String
}

struct AppSegmentedControl: View {
    let options: [SegmentOption]
    let selectedID: String
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 5) {
            ForEach(options) { option in
                Button {
                    onSelect(option.id)
                } label: {
                    Text(option.title)
                        .font(.system(size: 10.5, weight: .semibold))
                        .foregroundStyle(selectedID == option.id ? Color.appTextPrimary : Color.appTextSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background {
                            if selectedID == option.id {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Color.appElevated)
                                    .shadow(color: .black.opacity(0.12), radius: 1, y: 1)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Color.appFill))
    }
}

struct SettingsButtonRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var danger: Bool = false
    var chevron: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SettingsRowContent(
                icon: icon,
                title: title,
                subtitle: subtitle,
                value: value,
                danger: danger,
                chevron: chevron
            )
        }
        .buttonStyle(.plain)
    }
}

struct SettingsInfoRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil

    var body: some View {
        SettingsRowContent(icon: icon, title: title, subtitle: subtitle, value: value, danger: false, chevron: false)
    }
}

struct SettingsRowContent: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var danger: Bool
    var chevron: Bool

    var body: some View {
        HStack(spacing: 11) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(danger ? Color.appDangerText : Color.appTextSecondary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(danger ? Color.appDanger.opacity(0.12) : Color.appFill)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(danger ? Color.appDangerText : Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 10.5))
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.leading)
                }
            }
            Spacer(minLength: 8)
            if let value {
                Text(value)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Color.appTextTertiary)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
            }
            if chevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.appTextTertiary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

struct SettingsDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.appSeparator)
            .frame(height: 0.5)
            .padding(.leading, 53)
    }
}

struct SettingsGroup<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: 10.5, weight: .bold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(Color.appTextTertiary)
                .padding(.horizontal, 4)
            VStack(spacing: 0) {
                content
            }
            .background(Color.appCard)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            }
        }
    }
}

struct SheetChrome<Content: View>: View {
    @Environment(\.dismiss) private var dismiss
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 30, height: 30)
                            .background(Circle().fill(Color.appFill))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(L10n.t("close", language: appLanguage))
                }
                .padding(.bottom, 8)
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.appElevated)
    }

    @EnvironmentObject private var app: AppState

    private var appLanguage: AppLanguage { app.language }
}

struct ToastView: View {
    let item: ToastItem
    let onAction: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Text(item.message)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 4)
            if let actionTitle = item.actionTitle {
                Button {
                    onAction()
                } label: {
                    Text(actionTitle)
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Color(hex: 0x5EEAD4))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(Color(hex: 0x1C1C1E).opacity(0.96))
        )
        .shadow(color: .black.opacity(0.28), radius: 17, x: 0, y: 8)
        .padding(.horizontal, 20)
        .onTapGesture {
            if item.actionTitle == nil { onDismiss() }
        }
        .accessibilityElement(children: .combine)
    }
}
