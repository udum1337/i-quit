import SwiftUI

struct SheetIcon: View {
    let icon: String
    var accent: Bool = true
    var danger: Bool = false

    var body: some View {
        Image(systemName: icon)
            .font(.system(size: 27, weight: .semibold))
            .foregroundStyle(foreground)
            .frame(width: 62, height: 62)
            .background(
                RoundedRectangle(cornerRadius: 19, style: .continuous)
                    .fill(background)
            )
            .padding(.bottom, 16)
    }

    private var foreground: Color {
        if danger { return Color.appDangerText }
        return accent ? Color.appAccent : Color.appTextSecondary
    }

    private var background: Color {
        if danger { return Color.appDanger.opacity(0.12) }
        return accent ? Color.appAccentSoft : Color.appFill
    }
}

struct SheetTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 26, weight: .heavy))
            .tracking(-1)
            .foregroundStyle(Color.appTextPrimary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct SheetBodyText: View {
    let text: String
    var tertiary: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .lineSpacing(4)
            .foregroundStyle(tertiary ? Color.appTextTertiary : Color.appTextSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }
}

struct DetailPill: View {
    let text: String
    var accent: Bool = false

    var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .bold))
            .foregroundStyle(accent ? Color.appAccent : Color.appTextSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(accent ? Color.appAccentSoft : Color.appFill)
            )
    }
}

struct SheetSectionLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 10.5, weight: .bold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(Color.appTextTertiary)
    }
}

struct SheetQuote: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 13))
            .lineSpacing(4)
            .foregroundStyle(Color.appTextPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appAccentSoft.opacity(0.7))
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color.appAccent)
                    .frame(width: 3)
                    .padding(.vertical, 12)
            }
    }
}

struct SourceLinkRow: View {
    let source: HealthSource
    let language: AppLanguage

    private var url: URL? {
        URL(string: source.url)
    }

    var body: some View {
        Group {
            if let url {
                Link(destination: url) {
                    content
                }
            } else {
                content
            }
        }
        .buttonStyle(.plain)
    }

    private var content: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(Color.appAccentSoft)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(source.org)
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.6)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.appAccent)
                Text(source.title.value(language))
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(source.url)
                    .font(.system(size: 9.5))
                    .foregroundStyle(Color.appTextTertiary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer(minLength: 6)

            Image(systemName: "arrow.up.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.appTextTertiary)
                .padding(.top, 4)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.appCard)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.appSeparator, lineWidth: 1)
        }
        .contentShape(Rectangle())
    }
}

struct PrimarySheetButton: View {
    let title: String
    var danger: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    Group {
                        if danger {
                            Color.appDanger
                        } else {
                            Color.buttonGradient
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(
                    color: (danger ? Color.appDanger : Color(hex: 0x0A84FF)).opacity(0.22),
                    radius: 12,
                    y: 7
                )
        }
        .buttonStyle(.plain)
    }
}

struct SecondarySheetButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.appTextPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.appFill)
                )
        }
        .buttonStyle(.plain)
    }
}
