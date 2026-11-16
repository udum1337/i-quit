import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var app: AppState
    let plan: UserPlan
    let onSeeAll: () -> Void

    private var language: AppLanguage { app.language }
    private var now: Date { app.now }
    private var state: MilestoneState { plan.milestoneState(at: now) }

    private func t(_ key: String) -> String {
        app.t(key)
    }

    private var sourceOrgs: String {
        guard let current = state.previous else { return "WHO · NHS" }
        return current.sources
            .prefix(2)
            .compactMap { HealthSourceCatalog.byID[$0]?.org }
            .joined(separator: " · ")
    }

    private var previewAchievements: [Achievement] {
        let unlocked = plan.unlockedAchievements(at: now)
        let locked = plan.lockedAchievements(at: now)
        return Array((unlocked + locked).prefix(8))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(
                    eyebrow: Format.dateLong(now, language: language),
                    title: t("overview"),
                    subtitle: t("overviewSub")
                )

                hero

                nextCard
                    .padding(.top, 12)

                benefitCard
                    .padding(.top, 12)

                statsGrid
                    .padding(.top, 12)

                achievementsSection
                    .padding(.top, 22)

                footer
                    .padding(.top, 18)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
    }

    // MARK: - Hero

    private var hero: some View {
        ZStack {
            Color.heroGradient

            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.22), lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: max(0, min(1, state.progress)))
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .shadow(color: .white.opacity(0.35), radius: 3)

                    VStack(spacing: 0) {
                        Text("\(plan.currentDays(at: now))")
                            .font(.system(size: 56, weight: .heavy))
                            .tracking(-2.8)
                            .monospacedDigit()
                            .foregroundStyle(.white)
                        Text(Plural.days(Double(plan.currentDays(at: now)), language: language))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.84))
                            .padding(.top, 5)
                        Text(Format.hms(plan.elapsed(at: now)))
                            .font(.system(size: 12, weight: .bold))
                            .monospacedDigit()
                            .tracking(1.2)
                            .foregroundStyle(.white.opacity(0.88))
                            .padding(.top, 9)
                    }
                }
                .frame(width: 192, height: 192)

                HStack(spacing: 5) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11, weight: .semibold))
                    Text("\(t("bestStreak")): ")
                        .font(.system(size: 11, weight: .medium))
                    Text("\(plan.bestDays(at: now)) \(Plural.days(Double(plan.bestDays(at: now)), language: language))")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Capsule().fill(Color.white.opacity(0.17)))
                .padding(.top, 8)

                Text(state.next.map { Format.countdown($0.at - state.elapsed, language: language) } ?? t("allMilestonesDone"))
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(.white.opacity(0.82))
                    .padding(.top, 6)
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.white.opacity(0.14))
                .frame(width: 230, height: 230)
                .offset(x: 70, y: -130)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 150, height: 150)
                .offset(x: -50, y: 90)
                .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(hex: 0x0A84FF).opacity(0.22), radius: 22, x: 0, y: 12)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(plan.currentDays(at: now)) \(Plural.days(Double(plan.currentDays(at: now)), language: language))")
    }

    // MARK: - Next milestone

    private var nextCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            cardLabel(t("nextMilestone"))

            HStack(spacing: 11) {
                Image(systemName: state.next?.icon ?? "checkmark")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.appAccentSoft))

                VStack(alignment: .leading, spacing: 2) {
                    Text(state.next?.title.value(language) ?? t("allMilestonesDone"))
                        .font(.system(size: 15, weight: .bold))
                        .tracking(-0.3)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                    Text(state.next.map { Format.countdown($0.at - state.elapsed, language: language) } ?? t("allDone"))
                        .font(.system(size: 11.5))
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer(minLength: 0)
            }

            ProgressTrack(progress: state.progress)
        }
        .appCard()
    }

    // MARK: - Current benefit

    private var benefitCard: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 11) {
                Image(systemName: state.previous?.icon ?? "heart.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 42, height: 42)
                    .background(RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.benefitGradient))

                VStack(alignment: .leading, spacing: 2) {
                    cardLabel(t("nowInBody"))
                    Text(state.previous?.title.value(language) ?? t("startBenefitTitle"))
                        .font(.system(size: 15, weight: .bold))
                        .tracking(-0.3)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                }
                Spacer(minLength: 0)
            }

            Text(state.previous?.desc.value(language) ?? t("startBenefitDesc"))
                .font(.system(size: 12.5))
                .lineSpacing(4)
                .foregroundStyle(Color.appTextSecondary)

            SourceChip(
                icon: "info.circle",
                text: "\(t("source")): \(sourceOrgs)",
                action: {
                    app.sheet = .milestone(state.previous?.id ?? HealthMilestones.all[0].id)
                }
            )
        }
        .appCard()
    }

    // MARK: - Stats

    private var statsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ],
            spacing: 10
        ) {
            StatCard(
                icon: "banknote.fill",
                value: plan.money(plan.savedTotal(at: now), language: language),
                label: t("moneySaved")
            )
            StatCard(
                icon: "nosign",
                value: plan.formatAvoided(at: now, language: language),
                label: t("cigarettesAvoided")
            )
            StatCard(
                icon: "trophy.fill",
                value: Format.days(Double(plan.bestDays(at: now)), language: language),
                label: t("bestLabel")
            )
            StatCard(
                icon: "calendar",
                value: Format.days(Double(plan.totalDays(at: now)), language: language),
                label: t("totalLabel")
            )
        }
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(t("achievements"))
                    .font(.system(size: 17, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Button(t("seeAll"), action: onSeeAll)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.appAccent)
                    .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 9) {
                    ForEach(previewAchievements) { achievement in
                        let unlocked = plan.isAchievementUnlocked(achievement, at: now)
                        Button {
                            app.sheet = .achievement(achievement.id)
                        } label: {
                            VStack(spacing: 6) {
                                AchievementIcon(icon: achievement.icon, size: 38, locked: !unlocked)
                                Text(achievement.title.value(language))
                                    .font(.system(size: 9.5, weight: .semibold))
                                    .foregroundStyle(Color.appTextPrimary)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                            .frame(width: 78)
                            .padding(.vertical, 11)
                            .padding(.horizontal, 6)
                            .background(Color.appCard, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .opacity(unlocked ? 1 : 0.48)
                            .shadow(color: Color.black.opacity(0.04), radius: 10, y: 4)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 2)
            }
            .padding(.horizontal, -18)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            SourceChip(
                icon: "checkmark.shield.fill",
                text: t("sources"),
                action: { app.sheet = .sources }
            )
            Text(t("settingsFooter"))
                .font(.system(size: 10))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextTertiary)
                .padding(.horizontal, 12)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity)
    }

    private func cardLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold))
            .tracking(0.8)
            .textCase(.uppercase)
            .foregroundStyle(Color.appTextTertiary)
    }
}
