import SwiftUI

struct AchievementDetailView: View {
    @EnvironmentObject private var app: AppState
    let achievementID: String
    let plan: UserPlan?

    private var language: AppLanguage { app.language }
    private var achievement: Achievement? { Achievements.byID[achievementID] }

    var body: some View {
        SheetChrome {
            if let achievement {
                content(for: achievement)
            } else {
                Text(app.t("noData"))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private func content(for achievement: Achievement) -> some View {
        let unlocked = plan?.isAchievementUnlocked(achievement, at: app.now) ?? false
        let description = plan?.achievementDescription(achievement, language: language)
            ?? achievement.desc.value(language)

        return VStack(alignment: .leading, spacing: 0) {
            SheetIcon(icon: achievement.icon, accent: unlocked)

            DetailPill(
                text: app.t(unlocked ? "achievementEarned" : "achievementLocked"),
                accent: unlocked
            )

            SheetTitle(text: achievement.title.value(language))
                .padding(.top, 10)

            SheetBodyText(text: description)
                .padding(.top, 14)

            if !unlocked, let progressText {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered")
                        .font(.system(size: 12, weight: .semibold))
                    Text(progressText)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(Color.appTextSecondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.appFill)
                )
                .padding(.top, 16)
            }

            SecondarySheetButton(title: app.t("close")) {
                app.sheet = nil
            }
            .padding(.top, 24)
        }
    }

    private var progressText: String? {
        guard let achievement, let plan else { return nil }
        switch achievement.type {
        case .time:
            let remaining = max(0, achievement.value - plan.elapsed(at: app.now))
            guard remaining > 0 else { return nil }
            return "\(app.t("unlockIn")) \(Format.durationShort(remaining, language: language))"
        case .money:
            let current = plan.savedTotal(at: app.now)
            let target = achievement.value
            let currentText = Format.money(current, currency: plan.currency, language: language)
            let targetText = Format.money(target, currency: plan.currency, language: language)
            return "\(currentText) \(app.t("of")) \(targetText)"
        case .slip:
            return nil
        }
    }
}
