import SwiftUI
import SwiftData
import UIKit

struct ShareItem: Identifiable {
    let id = UUID()
    let url: URL
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct SettingsScreen: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.modelContext) private var context
    let plan: UserPlan
    let onEditPlan: () -> Void

    @State private var shareItem: ShareItem?

    private var language: AppLanguage { app.language }
    private var now: Date { app.now }

    private func t(_ key: String) -> String { app.t(key) }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ScreenHeader(
                    eyebrow: t("settingsSub"),
                    title: t("settingsTitle"),
                    subtitle: nil
                )

                profileCard

                planGroup
                    .padding(.top, 16)

                notificationsGroup
                    .padding(.top, 16)

                appearanceGroup
                    .padding(.top, 16)

                dataGroup
                    .padding(.top, 16)

                aboutGroup
                    .padding(.top, 16)

                footer
                    .padding(.top, 20)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 28)
        }
        .scrollIndicators(.hidden)
        .background(Color.appBackground)
        .sheet(item: $shareItem) { item in
            ActivityView(activityItems: [item.url])
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var profileCard: some View {
        HStack(spacing: 12) {
            Image(systemName: plan.product.icon)
                .font(.system(size: 23, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 50, height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(Color.heroGradient)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(plan.product.name.value(language))
                    .font(.system(size: 15, weight: .bold))
                    .tracking(-0.3)
                    .foregroundStyle(Color.appTextPrimary)
                Text(plan.formatProfileSub(at: now, language: language))
                    .font(.system(size: 11))
                    .foregroundStyle(Color.appTextSecondary)
            }

            Spacer(minLength: 8)

            Button(t("edit"), action: onEditPlan)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(Color.appAccent)
                .buttonStyle(.plain)
        }
        .appCard(padding: 14)
    }

    private var planGroup: some View {
        SettingsGroup(title: t("planGroup")) {
            SettingsButtonRow(
                icon: plan.product.icon,
                title: t("product"),
                value: plan.product.name.value(language),
                action: onEditPlan
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "calendar",
                title: t("quitDate"),
                value: Format.dateTime(plan.quitDate, language: language),
                action: onEditPlan
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "waveform.path.ecg",
                title: t("consumption"),
                value: plan.formatConsumption(language: language),
                action: onEditPlan
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "banknote.fill",
                title: t("price"),
                value: plan.formatPrice(language: language),
                action: onEditPlan
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "banknote.fill",
                title: t("currency"),
                value: Format.currencyValue(plan.currency),
                action: { app.sheet = .currency }
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "arrow.clockwise",
                title: t("slipRow"),
                subtitle: t("slipRowSub"),
                danger: true,
                action: { app.sheet = .slip }
            )
        }
    }

    private var notificationsGroup: some View {
        SettingsGroup(title: t("notifications")) {
            HStack(spacing: 11) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.appFill))

                VStack(alignment: .leading, spacing: 2) {
                    Text(t("notifications"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                    Text(t("notificationsSub"))
                        .font(.system(size: 10.5))
                        .foregroundStyle(Color.appTextSecondary)
                }

                Spacer(minLength: 8)

                Toggle(
                    "",
                    isOn: Binding(
                        get: { plan.notificationsEnabled },
                        set: { newValue in
                            plan.notificationsEnabled = newValue
                            try? context.save()
                            if newValue {
                                Task { @MainActor in
                                    let granted = await NotificationService.requestAuthorization()
                                    if granted {
                                        app.rescheduleNotifications(for: plan)
                                    } else {
                                        plan.notificationsEnabled = false
                                        try? context.save()
                                        app.showToast(app.t("notificationsDenied"))
                                    }
                                }
                            } else {
                                app.rescheduleNotifications(for: plan)
                            }
                        }
                    )
                )
                .labelsHidden()
                .tint(Color.appAccent)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }

    private var appearanceGroup: some View {
        SettingsGroup(title: t("appearance")) {
            segmentedRow(
                icon: "moon.fill",
                title: t("appearance"),
                options: ThemeMode.allCases.map {
                    SegmentOption(id: $0.rawValue, title: themeTitle($0))
                },
                selected: app.theme.rawValue,
                onSelect: { value in
                    if let theme = ThemeMode(rawValue: value) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            app.theme = theme
                        }
                    }
                }
            )
            SettingsDivider()
            segmentedRow(
                icon: "globe",
                title: t("language"),
                options: AppLanguage.allCases.map {
                    SegmentOption(id: $0.rawValue, title: $0.displayName)
                },
                selected: app.language.rawValue,
                onSelect: { value in
                    if let selected = AppLanguage(rawValue: value) {
                        app.language = selected
                        app.updateWidget(for: plan, at: now)
                        app.rescheduleNotifications(for: plan)
                    }
                }
            )
        }
    }

    private func segmentedRow(
        icon: String,
        title: String,
        options: [SegmentOption],
        selected: String,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 11) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 28, height: 28)
                    .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Color.appFill))
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.appTextPrimary)
            }
            AppSegmentedControl(options: options, selectedID: selected, onSelect: onSelect)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private var dataGroup: some View {
        SettingsGroup(title: t("dataGroup")) {
            SettingsButtonRow(
                icon: "square.and.arrow.down",
                title: t("exportData"),
                subtitle: t("exportDataSub"),
                action: exportData
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "trash",
                title: t("resetData"),
                subtitle: t("resetDataSub"),
                danger: true,
                action: { app.sheet = .reset }
            )
        }
    }

    private var aboutGroup: some View {
        SettingsGroup(title: t("aboutGroup")) {
            SettingsButtonRow(
                icon: "checkmark.shield.fill",
                title: t("sourcesRow"),
                subtitle: t("sourcesRowSub"),
                action: { app.sheet = .sources }
            )
            SettingsDivider()
            SettingsButtonRow(
                icon: "info.circle",
                title: t("disclaimerRow"),
                subtitle: t("disclaimerRowSub"),
                action: { app.sheet = .disclaimer }
            )
            SettingsDivider()
            SettingsInfoRow(
                icon: "sparkles",
                title: t("version"),
                subtitle: "\(t("appName")) · iOS",
                value: appVersion
            )
        }
    }

    private var footer: some View {
        VStack(spacing: 3) {
            Text(t("appName"))
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.appTextSecondary)
            Text(t("madeWith"))
                .font(.system(size: 10))
                .foregroundStyle(Color.appTextTertiary)
            Text(t("settingsFooter"))
                .font(.system(size: 10))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundStyle(Color.appTextTertiary)
                .padding(.top, 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
    }

    private var appVersion: String {
        let info = Bundle.main.infoDictionary
        let version = info?["CFBundleShortVersionString"] as? String ?? "1.0.0"
        let build = info?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func themeTitle(_ theme: ThemeMode) -> String {
        switch theme {
        case .system: return t("system")
        case .light: return t("light")
        case .dark: return t("dark")
        }
    }

    private func exportData() {
        let formatter = ISO8601DateFormatter()
        let data: [String: Any] = [
            "app": "Не курю / I Quit",
            "exportedAt": formatter.string(from: now),
            "quitDate": formatter.string(from: plan.quitDate),
            "product": plan.product.rawValue,
            "productLabel": plan.product.name.value(language),
            "unitsPerDay": (plan.unitsPerDay * 100).rounded() / 100,
            "pricePerPackage": plan.pricePerPackage,
            "unitsPerPackage": plan.unitsPerPackage,
            "currency": plan.currency.rawValue,
            "currentStreakSeconds": Int(plan.elapsed(at: now)),
            "bestStreakSeconds": Int(plan.bestSeconds(at: now)),
            "totalCleanSeconds": Int(plan.totalCleanSeconds(at: now)),
            "slips": plan.slips,
            "moneySaved": Int(plan.savedTotal(at: now).rounded()),
            "avoidedUnits": Int(plan.avoidedTotal(at: now).rounded()),
            "achievements": plan.unlockedAchievements(at: now).map(\.id),
            "notifications": plan.notificationsEnabled
        ]

        guard
            let json = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted, .sortedKeys])
        else { return }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("i-quit-data.json")
        do {
            try json.write(to: url, options: .atomic)
            shareItem = ShareItem(url: url)
            app.showToast(t("exportToast"))
        } catch {
            app.showToast(t("noData"))
        }
    }
}
