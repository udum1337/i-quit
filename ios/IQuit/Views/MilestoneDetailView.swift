import SwiftUI

struct MilestoneDetailView: View {
    @EnvironmentObject private var app: AppState
    let milestoneID: String
    let plan: UserPlan?

    private var language: AppLanguage { app.language }
    private var milestone: HealthMilestone? { HealthMilestones.byID[milestoneID] }
    private var elapsed: TimeInterval { plan?.elapsed(at: app.now) ?? 0 }

    var body: some View {
        SheetChrome {
            if let milestone {
                content(for: milestone)
            } else {
                Text(app.t("noData"))
                    .font(.system(size: 13))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
    }

    private func content(for milestone: HealthMilestone) -> some View {
        let unlocked = elapsed >= milestone.at
        let remaining = max(0, milestone.at - elapsed)

        return VStack(alignment: .leading, spacing: 0) {
            SheetIcon(icon: milestone.icon, accent: unlocked)

            DetailPill(
                text: app.t(unlocked ? "milestoneEarned" : "milestoneLocked"),
                accent: unlocked
            )

            SheetTitle(text: milestone.title.value(language))
                .padding(.top, 10)

            HStack(spacing: 6) {
                DetailPill(text: milestone.time.value(language))
                DetailPill(
                    text: app.t(unlocked ? "unlockedAt" : "locked"),
                    accent: unlocked
                )
            }
            .padding(.top, 10)

            SheetBodyText(text: milestone.desc.value(language))
                .padding(.top, 14)

            SheetQuote(text: milestone.long.value(language))
                .padding(.top, 14)

            if !unlocked {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 11, weight: .semibold))
                    Text("\(app.t("unlockIn")) \(Format.durationShort(remaining, language: language))")
                        .font(.system(size: 11.5, weight: .semibold))
                }
                .foregroundStyle(Color.appAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Capsule().fill(Color.appAccentSoft))
                .padding(.top, 14)
            }

            VStack(alignment: .leading, spacing: 8) {
                SheetSectionLabel(text: app.t("sourcesLabel"))
                    .padding(.bottom, 2)

                ForEach(milestone.sources.compactMap { HealthSourceCatalog.byID[$0] }, id: \.id) { source in
                    SourceLinkRow(source: source, language: language)
                }
            }
            .padding(.top, 22)

            SheetBodyText(text: app.t("settingsFooter"), tertiary: true)
                .padding(.top, 16)
        }
    }
}
