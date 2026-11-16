import SwiftUI

struct TimelineScreen: View {
    @EnvironmentObject private var app: AppState
    let plan: UserPlan

    private var language: AppLanguage { app.language }
    private var now: Date { app.now }
    private var state: MilestoneState { plan.milestoneState(at: now) }

    private func t(_ key: String) -> String { app.t(key) }

    private struct TimelineRow: Identifiable {
        enum Kind {
            case milestone(HealthMilestone, Bool)
            case marker
        }

        let id: String
        let kind: Kind
    }

    private struct TimelineGroupRows: Identifiable {
        let group: MilestoneGroup
        let rows: [TimelineRow]
        var id: String { group.rawValue }
    }

    private var groupRows: [TimelineGroupRows] {
        var markerInserted = false
        var result: [TimelineGroupRows] = []

        for group in MilestoneGroup.allCases {
            var rows: [TimelineRow] = []
            for milestone in HealthMilestones.all where milestone.group == group {
                let unlocked = state.elapsed >= milestone.at
                if !unlocked && !markerInserted {
                    rows.append(TimelineRow(id: "marker", kind: .marker))
                    markerInserted = true
                }
                rows.append(
                    TimelineRow(
                        id: milestone.id,
                        kind: .milestone(milestone, unlocked)
                    )
                )
            }
            if !rows.isEmpty {
                result.append(TimelineGroupRows(group: group, rows: rows))
            }
        }
        return result
    }

    private var markerAtEnd: Bool {
        state.elapsed >= (HealthMilestones.all.last?.at ?? 0)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(
                    eyebrow: t("progressLabel"),
                    title: t("timelineTitle"),
                    subtitle: t("timelineSub")
                )

                summary

                if plan.product != .cigarettes {
                    productNote
                        .padding(.top, 10)
                }

                ForEach(groupRows) { group in
                    VStack(alignment: .leading, spacing: 9) {
                        Text(t(group.group.labelKey))
                            .font(.system(size: 11, weight: .bold))
                            .tracking(0.8)
                            .textCase(.uppercase)
                            .foregroundStyle(Color.appTextTertiary)
                            .padding(.horizontal, 4)

                        ForEach(group.rows) { row in
                            switch row.kind {
                            case .milestone(let milestone, let unlocked):
                                milestoneRow(milestone, unlocked: unlocked)
                            case .marker:
                                markerRow
                            }
                        }
                    }
                    .padding(.top, 18)
                }

                if markerAtEnd {
                    markerRow
                        .padding(.top, 4)
                }

                footer
                    .padding(.top, 18)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
    }

    private var summary: some View {
        let overall = Double(state.unlocked.count) / Double(max(1, HealthMilestones.all.count))
        let summarySub: String
        if let next = state.next {
            summarySub = "\(t("unlockIn")) \(Format.durationShort(next.at - state.elapsed, language: language)) · \(next.time.value(language))"
        } else {
            summarySub = t("allDone")
        }

        return VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(t("timelineSummary"))
                    .font(.system(size: 14, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
                Text("\(state.unlocked.count) \(t("of")) \(HealthMilestones.all.count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.appAccent)
            }

            ProgressTrack(progress: overall)
                .padding(.top, 10)

            Text(summarySub)
                .font(.system(size: 11))
                .foregroundStyle(Color.appTextSecondary)
                .padding(.top, 8)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.appAccent.opacity(0.14), Color.appAccent2.opacity(0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.appAccent.opacity(0.16), lineWidth: 1)
        }
    }

    private var productNote: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "info.circle")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Color.appAccent)
                .padding(.top, 1)
            Text(t("timelineProductNote"))
                .font(.system(size: 10.5))
                .lineSpacing(2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color.appFill))
    }

    private func milestoneRow(_ milestone: HealthMilestone, unlocked: Bool) -> some View {
        Button {
            app.sheet = .milestone(milestone.id)
        } label: {
            HStack(alignment: .top, spacing: 10) {
                timelineDot(checked: unlocked)
                    .frame(width: 22)
                    .padding(.top, 14)

                VStack(alignment: .leading, spacing: 3) {
                    Text(milestone.time.value(language))
                        .font(.system(size: 9.5, weight: .bold))
                        .tracking(0.8)
                        .textCase(.uppercase)
                        .foregroundStyle(unlocked ? Color.appAccent : Color.appTextTertiary)
                    Text(milestone.title.value(language))
                        .font(.system(size: 13.5, weight: .bold))
                        .tracking(-0.2)
                        .foregroundStyle(Color.appTextPrimary)
                        .multilineTextAlignment(.leading)
                    Text(milestone.desc.value(language))
                        .font(.system(size: 11.5))
                        .lineSpacing(2)
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(unlocked ? Color.appCard : Color.clear)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(unlocked ? Color.white.opacity(0.06) : Color.appSeparator, lineWidth: 1)
                }
                .shadow(color: Color.black.opacity(unlocked ? 0.04 : 0), radius: 10, y: 4)
                .opacity(unlocked ? 1 : 0.62)
            }
            .background(alignment: .topLeading) {
                Rectangle()
                    .fill(Color.appSeparator)
                    .frame(width: 2)
                    .padding(.leading, 10)
                    .padding(.top, 24)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var markerRow: some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.appAccent.opacity(0.22))
                    .frame(width: 22, height: 22)
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 22)
            .padding(.top, 2)

            HStack(spacing: 5) {
                Image(systemName: "target")
                    .font(.system(size: 10, weight: .semibold))
                Text("\(t("youAreHere")) · \(Format.days(Double(plan.currentDays(at: now)), language: language))")
                    .font(.system(size: 10.5, weight: .bold))
            }
            .foregroundStyle(Color.appAccent)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Capsule().fill(Color.appAccentSoft))
            .padding(.bottom, 9)
        }
    }

    private func timelineDot(checked: Bool) -> some View {
        ZStack {
            Circle()
                .fill(checked ? Color.appAccent : Color.appBackground)
            Circle()
                .stroke(checked ? Color.appAccent : Color.appSeparator, lineWidth: 2)
            if checked {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 22, height: 22)
    }

    private var footer: some View {
        VStack(spacing: 0) {
            SourceChip(
                icon: "checkmark.shield.fill",
                text: t("sourcesLabel"),
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
}
