import Foundation
import SwiftUI
import WidgetKit

struct ToastItem: Identifiable {
    let id = UUID()
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil
}

enum SheetRoute: Identifiable {
    case milestone(String)
    case achievement(String)
    case sources
    case disclaimer
    case slip
    case reset
    case currency

    var id: String {
        switch self {
        case .milestone(let id): return "milestone-\(id)"
        case .achievement(let id): return "achievement-\(id)"
        case .sources: return "sources"
        case .disclaimer: return "disclaimer"
        case .slip: return "slip"
        case .reset: return "reset"
        case .currency: return "currency"
        }
    }
}

@MainActor
final class AppState: ObservableObject {
    private enum Keys {
        static let language = "iquit.language"
        static let theme = "iquit.theme"
    }

    @Published var language: AppLanguage {
        didSet { UserDefaults.standard.set(language.rawValue, forKey: Keys.language) }
    }

    @Published var theme: ThemeMode {
        didSet { UserDefaults.standard.set(theme.rawValue, forKey: Keys.theme) }
    }

    @Published var now: Date = .now
    @Published var toast: ToastItem?
    @Published var sheet: SheetRoute?

    private var timer: Timer?
    private var toastTask: Task<Void, Never>?

    init() {
        let storedLanguage = UserDefaults.standard.string(forKey: Keys.language)
        let storedTheme = UserDefaults.standard.string(forKey: Keys.theme)
        language = storedLanguage.flatMap(AppLanguage.init(rawValue:)) ?? .systemDefault
        theme = storedTheme.flatMap(ThemeMode.init(rawValue:)) ?? .system

        let timer = Timer(timeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.now = Date()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    func t(_ key: String) -> String {
        L10n.t(key, language: language)
    }

    func showToast(_ message: String, actionTitle: String? = nil, action: (() -> Void)? = nil) {
        toastTask?.cancel()
        let item = ToastItem(message: message, actionTitle: actionTitle, action: action)
        withAnimation(.easeOut(duration: 0.2)) {
            toast = item
        }
        toastTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 6_000_000_000)
            guard !Task.isCancelled, let self else { return }
            guard self.toast?.id == item.id else { return }
            withAnimation(.easeIn(duration: 0.2)) {
                self.toast = nil
            }
        }
    }

    func dismissToast() {
        toastTask?.cancel()
        withAnimation(.easeIn(duration: 0.2)) {
            toast = nil
        }
    }

    func updateWidget(for plan: UserPlan, at date: Date = .now) {
        let snapshot = WidgetSnapshot(
            quitDate: plan.quitDate,
            bestStreakSeconds: plan.bestSeconds(at: date),
            costPerDay: plan.costPerDay,
            savedBase: plan.savedBase,
            currencySymbol: plan.currency.symbol,
            languageCode: language.rawValue,
            statusLabel: t("profileSub"),
            bestLabel: t("bestLabel"),
            nextLabel: t("nextMilestone"),
            savedLabel: t("moneySaved"),
            dayOne: t("day"),
            dayFew: t("days"),
            dayMany: t("daysMany"),
            allDoneText: t("allMilestonesDone"),
            milestones: HealthMilestones.all.map {
                WidgetMilestone(id: $0.id, at: $0.at, title: $0.title.value(language))
            },
            updatedAt: date
        )
        WidgetStore.save(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }

    func clearWidget() {
        WidgetStore.clear()
        WidgetCenter.shared.reloadAllTimelines()
    }

    func rescheduleNotifications(for plan: UserPlan) {
        NotificationService.reschedule(for: plan, language: language)
    }
}
