import SwiftUI
import Charts

struct ProgressScreen: View {
    @EnvironmentObject private var app: AppState
    let plan: UserPlan
    let onOpenTimeline: () -> Void

    private var language: AppLanguage { app.language }
    private var now: Date { app.now }
    private var state: MilestoneState { plan.milestoneState(at: now) }

    private func t(_ key: String) -> String { app.t(key) }

    private struct HeatCell: Identifiable {
        let id: String
        let date: Date
        let isClean: Bool
        let isToday: Bool
        let isFuture: Bool
    }

    private struct SavingPoint: Identifiable {
        let id: Int
        let day: Double
        let value: Double
    }

    private var totalDays: Int { plan.totalDays(at: now) }

    private var savingsPoints: [SavingPoint] {
        let cleanDays = plan.totalCleanSeconds(at: now) / 86_400
        let priorDays = plan.priorCleanSeconds / 86_400
        let steps = max(1, min(60, max(1, totalDays)))
        return (0...steps).map { index in
            let day = cleanDays == 0 ? 0 : Double(index) / Double(steps) * cleanDays
            let value: Double
            if priorDays > 0 && day <= priorDays {
                value = plan.savedBase * (day / priorDays)
            } else {
                value = plan.savedBase + plan.costPerDay * max(0, day - priorDays)
            }
            return SavingPoint(id: index, day: day, value: value)
        }
    }

    private var maxSaving: Double {
        max(1, plan.savedTotal(at: now))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(
                    eyebrow: t("progressWord"),
                    title: t("progressTitle"),
                    subtitle: t("progressSub")
                )

                progressHero

                heatmap
                    .padding(.top, 10)

                savingsChart
                    .padding(.top, 10)

                achievementsSection
                    .padding(.top, 22)

                milestonesCard
                    .padding(.top, 14)

                footer
                    .padding(.top, 16)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
    }

    // MARK: - Hero

    private var progressHero: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(plan.currentDays(at: now))")
                        .font(.system(size: 38, weight: .heavy))
                        .tracking(-1.9)
                        .monospacedDigit()
                        .foregroundStyle(.white)
                    Text(Plural.days(Double(plan.currentDays(at: now)), language: language))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.top, 4)
                }
                Spacer(minLength: 12)
                Text("\(t("currentStreak")) · \(t("slips")): \(plan.slips)")
                    .font(.system(size: 10.5))
                    .foregroundStyle(.white.opacity(0.78))
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
            .background(Color.heroGradient)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: Color(hex: 0x0A84FF).opacity(0.2), radius: 17, y: 8)

            VStack(spacing: 10) {
                miniStat(value: "\(plan.bestDays(at: now))", label: t("bestStreakShort"))
                miniStat(value: "\(totalDays)", label: t("totalCleanShort"))
            }
            .frame(width: 128)
        }
    }

    private func miniStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(value)
                .font(.system(size: 21, weight: .heavy))
                .tracking(-0.9)
                .monospacedDigit()
                .foregroundStyle(Color.appTextPrimary)
            Text(label)
                .font(.system(size: 10))
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 12, radius: 18)
    }

    // MARK: - Heatmap

    private var heatmap: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(t("cleanDaysTitle"))
                    .font(.system(size: 14, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text(t("cleanDaysSub"))
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.appTextTertiary)
            }

            HStack(alignment: .top, spacing: 7) {
                VStack(spacing: 3) {
                    ForEach(Array(["wdMon", "", "wdWed", "", "wdFri", "", "wdSun"].enumerated()), id: \.offset) { _, key in
                        Text(key.isEmpty ? " " : t(key))
                            .font(.system(size: 7.5))
                            .foregroundStyle(Color.appTextTertiary)
                            .frame(height: 12, alignment: .trailing)
                    }
                }
                .frame(width: 18, alignment: .trailing)

                HStack(spacing: 3) {
                    ForEach(0..<heatmapWeeks.count, id: \.self) { weekIndex in
                        VStack(spacing: 3) {
                            ForEach(heatmapWeeks[weekIndex]) { cell in
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .fill(cell.isClean ? Color.appAccent.opacity(0.9) : Color.appFill)
                                    .frame(width: 12, height: 12)
                                    .overlay {
                                        if cell.isToday {
                                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                                .stroke(Color.appTextPrimary, lineWidth: 1.5)
                                        }
                                    }
                                    .opacity(cell.isFuture ? 0 : 1)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.top, 14)

            HStack(spacing: 12) {
                legendDot(color: Color.appFill, text: t("legendBefore"))
                legendDot(color: Color.appAccent, text: t("legendClean"))
            }
            .padding(.top, 11)
        }
        .appCard()
    }

    private var heatmapWeeks: [[HeatCell]] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = language.locale
        calendar.firstWeekday = 2

        let today = calendar.startOfDay(for: now)
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday + 5) % 7
        let thisMonday = calendar.date(byAdding: .day, value: -daysFromMonday, to: today) ?? today
        let start = calendar.date(byAdding: .day, value: -11 * 7, to: thisMonday) ?? thisMonday
        let quitDay = calendar.startOfDay(for: plan.quitDate)

        return (0..<12).map { week in
            (0..<7).map { day in
                let date = calendar.date(byAdding: .day, value: week * 7 + day, to: start) ?? start
                let isFuture = date > today
                let isClean = date >= quitDay && !isFuture
                return HeatCell(
                    id: "\(week)-\(day)",
                    date: date,
                    isClean: isClean,
                    isToday: calendar.isDate(date, inSameDayAs: today),
                    isFuture: isFuture
                )
            }
        }
    }

    private func legendDot(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(color)
                .frame(width: 9, height: 9)
            Text(text)
                .font(.system(size: 9.5))
                .foregroundStyle(Color.appTextTertiary)
        }
    }

    // MARK: - Savings chart

    private var savingsChart: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(t("savingsTitle"))
                        .font(.system(size: 14, weight: .bold))
                        .tracking(-0.3)
                        .foregroundStyle(Color.appTextPrimary)
                    Text(plan.money(plan.savedTotal(at: now), language: language))
                        .font(.system(size: 22, weight: .heavy))
                        .tracking(-0.9)
                        .monospacedDigit()
                        .foregroundStyle(Color.appTextPrimary)
                        .padding(.top, 2)
                    Text("\(t("forDays")) \(Format.days(Double(totalDays), language: language))")
                        .font(.system(size: 10.5))
                        .foregroundStyle(Color.appTextTertiary)
                        .padding(.top, 2)
                }
                Spacer()
                Image(systemName: "banknote.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.appAccent)
                    .frame(width: 29, height: 29)
                    .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(Color.appAccentSoft))
            }

            Chart {
                ForEach(savingsPoints) { point in
                    AreaMark(
                        x: .value("Day", point.day),
                        y: .value("Saved", point.value)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appAccent.opacity(0.32), Color.appAccent.opacity(0)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .interpolationMethod(.linear)

                    LineMark(
                        x: .value("Day", point.day),
                        y: .value("Saved", point.value)
                    )
                    .foregroundStyle(Color.appAccent)
                    .lineStyle(StrokeStyle(lineWidth: 2.4, lineCap: .round, lineJoin: .round))
                    .interpolationMethod(.linear)
                }

                RuleMark(y: .value("Middle", maxSaving / 2))
                    .foregroundStyle(Color.appSeparator)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 5]))
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .chartLegend(.hidden)
            .chartYScale(domain: 0...maxSaving)
            .frame(height: 104)
            .padding(.top, 8)
        }
        .appCard()
    }

    // MARK: - Achievements

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(t("achievementsTitle"))
                    .font(.system(size: 17, weight: .heavy))
                    .tracking(-0.5)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(plan.unlockedAchievements(at: now).count) \(t("of")) \(Achievements.all.count)")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.appTextTertiary)
            }
            .padding(.horizontal, 4)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 9), count: 4),
                spacing: 9
            ) {
                ForEach(Achievements.all) { achievement in
                    AchievementTile(
                        achievement: achievement,
                        unlocked: plan.isAchievementUnlocked(achievement, at: now),
                        language: language,
                        action: { app.sheet = .achievement(achievement.id) }
                    )
                }
            }
        }
    }

    // MARK: - Milestones

    private var milestonesCard: some View {
        let overall = Double(state.unlocked.count) / Double(max(1, HealthMilestones.all.count))
        return VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(t("milestonesTitle"))
                    .font(.system(size: 14, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(state.unlocked.count) \(t("of")) \(HealthMilestones.all.count)")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Color.appTextTertiary)
            }

            ProgressTrack(progress: overall)
                .padding(.top, 10)

            SourceChip(
                icon: "clock",
                text: t("navTimeline"),
                action: onOpenTimeline
            )
            .padding(.top, 11)
        }
        .appCard()
    }

    private var footer: some View {
        Text(t("settingsFooter"))
            .font(.system(size: 10))
            .lineSpacing(3)
            .multilineTextAlignment(.center)
            .foregroundStyle(Color.appTextTertiary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
    }
}
