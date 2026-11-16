import Foundation
import SwiftData

@Model
final class UserPlan {
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var hasCompletedOnboarding: Bool

    var productRaw: String
    var quitDate: Date
    var unitsPerDay: Double
    var pricePerPackage: Double
    var unitsPerPackage: Double
    var currencyRaw: String

    var priorCleanSeconds: Double
    var bestStreakSeconds: Double
    var savedBase: Double
    var avoidedBase: Double
    var slips: Int
    var notificationsEnabled: Bool
    var unlockedRaw: String

    init(
        product: ProductKind = .cigarettes,
        quitDate: Date = .now,
        unitsPerDay: Double = 20,
        pricePerPackage: Double = 250,
        unitsPerPackage: Double = 20,
        currency: CurrencyCode = .RUB,
        notificationsEnabled: Bool = true
    ) {
        self.id = UUID()
        self.createdAt = .now
        self.hasCompletedOnboarding = false
        self.productRaw = product.rawValue
        self.quitDate = quitDate
        self.unitsPerDay = unitsPerDay
        self.pricePerPackage = pricePerPackage
        self.unitsPerPackage = unitsPerPackage
        self.currencyRaw = currency.rawValue
        self.priorCleanSeconds = 0
        self.bestStreakSeconds = 0
        self.savedBase = 0
        self.avoidedBase = 0
        self.slips = 0
        self.notificationsEnabled = notificationsEnabled
        self.unlockedRaw = ""
    }

    var product: ProductKind {
        get { ProductKind(rawValue: productRaw) ?? .cigarettes }
        set { productRaw = newValue.rawValue }
    }

    var currency: CurrencyCode {
        get { CurrencyCode(rawValue: currencyRaw) ?? .RUB }
        set { currencyRaw = newValue.rawValue }
    }

    var unlockedIDs: [String] {
        get {
            unlockedRaw
                .split(separator: ",")
                .map(String.init)
                .filter { !$0.isEmpty }
        }
        set {
            unlockedRaw = newValue.joined(separator: ",")
        }
    }

    // MARK: - Time and money

    func elapsed(at now: Date) -> TimeInterval {
        max(0, now.timeIntervalSince(quitDate))
    }

    var costPerDay: Double {
        if product.isPerWeek {
            return pricePerPackage * unitsPerDay
        }
        let perUnit = pricePerPackage / max(1, unitsPerPackage)
        return perUnit * unitsPerDay
    }

    func savedTotal(at now: Date) -> Double {
        savedBase + costPerDay * (elapsed(at: now) / 86_400)
    }

    func avoidedTotal(at now: Date) -> Double {
        avoidedBase + unitsPerDay * (elapsed(at: now) / 86_400)
    }

    func totalCleanSeconds(at now: Date) -> TimeInterval {
        priorCleanSeconds + elapsed(at: now)
    }

    func bestSeconds(at now: Date) -> TimeInterval {
        max(bestStreakSeconds, elapsed(at: now))
    }

    func currentDays(at now: Date) -> Int {
        Int(elapsed(at: now) / 86_400)
    }

    func totalDays(at now: Date) -> Int {
        Int(totalCleanSeconds(at: now) / 86_400)
    }

    func bestDays(at now: Date) -> Int {
        Int(bestSeconds(at: now) / 86_400)
    }

    // MARK: - Milestones

    func milestoneState(at now: Date) -> MilestoneState {
        let elapsed = self.elapsed(at: now)
        let unlocked = HealthMilestones.all.filter { elapsed >= $0.at }
        let next = HealthMilestones.all.first { elapsed < $0.at }
        let previous = unlocked.last
        let start = previous?.at ?? 0
        let end = next?.at ?? max(elapsed, start + 1)
        let progress = next == nil ? 1 : min(1, max(0, (elapsed - start) / (end - start)))
        return MilestoneState(elapsed: elapsed, unlocked: unlocked, next: next, previous: previous, progress: progress)
    }

    func currentBenefit(at now: Date) -> HealthMilestone? {
        milestoneState(at: now).previous
    }

    // MARK: - Achievements

    func isAchievementUnlocked(_ achievement: Achievement, at now: Date) -> Bool {
        if unlockedIDs.contains(achievement.id) { return true }
        switch achievement.type {
        case .time:
            return elapsed(at: now) >= achievement.value
        case .money:
            return savedTotal(at: now) >= achievement.value
        case .slip:
            return slips > 0
        }
    }

    func unlockedAchievements(at now: Date) -> [Achievement] {
        Achievements.all.filter { isAchievementUnlocked($0, at: now) }
    }

    func lockedAchievements(at now: Date) -> [Achievement] {
        Achievements.all.filter { !isAchievementUnlocked($0, at: now) }
    }

    @discardableResult
    func syncAchievements(at now: Date) -> [Achievement] {
        var stored = Set(unlockedIDs)
        var newly: [Achievement] = []
        for achievement in Achievements.all where !stored.contains(achievement.id) {
            if isAchievementUnlocked(achievement, at: now) {
                stored.insert(achievement.id)
                newly.append(achievement)
            }
        }
        if !newly.isEmpty {
            unlockedIDs = Achievements.all.filter { stored.contains($0.id) }.map(\.id)
        }
        return newly
    }

    func achievementDescription(_ achievement: Achievement, language: AppLanguage) -> String {
        let text = achievement.desc.value(language)
        guard achievement.type == .money else { return text }
        return text.replacingOccurrences(of: "{amount}", with: money(achievement.value, language: language))
    }

    // MARK: - Display helpers

    func money(_ value: Double, language: AppLanguage) -> String {
        Format.money(value, currency: currency, language: language)
    }

    func formatConsumption(language: AppLanguage) -> String {
        if product.isPerWeek {
            let sessions = unitsPerDay * 7
            return Format.number(sessions, language: language, digits: 1)
                + " " + Plural.unit(sessions, product: product, language: language)
                + " " + L10n.t("perWeekShort", language: language)
        }
        return Format.number(unitsPerDay, language: language, digits: 1)
            + " " + Plural.unit(unitsPerDay, product: product, language: language)
    }

    func formatPrice(language: AppLanguage) -> String {
        if product.isPerWeek {
            return Format.money(pricePerPackage, currency: currency, language: language)
                + " · " + L10n.t("perSession", language: language)
        }
        let units = Format.number(unitsPerPackage, language: language)
            + " " + Plural.unit(unitsPerPackage, product: product, language: language)
        return Format.money(pricePerPackage, currency: currency, language: language) + " · " + units
    }

    func formatAvoided(at now: Date, language: AppLanguage) -> String {
        let total = avoidedTotal(at: now).rounded(.down)
        return Format.number(total, language: language)
            + " " + Plural.unit(total, product: product, language: language)
    }

    func formatProfileSub(at now: Date, language: AppLanguage) -> String {
        let days = currentDays(at: now)
        return "\(days) \(Plural.days(Double(days), language: language)) "
            + L10n.t("profileSub", language: language)
    }

    // MARK: - Slip

    /// Freezes the current streak into the lifetime totals, restarts the counter,
    /// and returns a snapshot that can restore the plan if the user undoes the slip.
    @discardableResult
    func recordSlip(at now: Date) -> PlanSnapshot {
        let snapshot = snapshot()
        // Persist any milestones earned by the streak before the counter resets.
        syncAchievements(at: now)
        let elapsed = self.elapsed(at: now)

        if elapsed > 0 {
            priorCleanSeconds += elapsed
            bestStreakSeconds = max(bestStreakSeconds, elapsed)
            savedBase = savedTotal(at: now)
            avoidedBase = avoidedTotal(at: now)
            quitDate = now
        }

        slips += 1
        syncAchievements(at: now)
        return snapshot
    }

    func snapshot() -> PlanSnapshot {
        PlanSnapshot(
            quitDate: quitDate,
            productRaw: productRaw,
            unitsPerDay: unitsPerDay,
            pricePerPackage: pricePerPackage,
            unitsPerPackage: unitsPerPackage,
            currencyRaw: currencyRaw,
            priorCleanSeconds: priorCleanSeconds,
            bestStreakSeconds: bestStreakSeconds,
            savedBase: savedBase,
            avoidedBase: avoidedBase,
            slips: slips,
            notificationsEnabled: notificationsEnabled,
            unlockedRaw: unlockedRaw
        )
    }

    func restore(_ snapshot: PlanSnapshot) {
        quitDate = snapshot.quitDate
        productRaw = snapshot.productRaw
        unitsPerDay = snapshot.unitsPerDay
        pricePerPackage = snapshot.pricePerPackage
        unitsPerPackage = snapshot.unitsPerPackage
        currencyRaw = snapshot.currencyRaw
        priorCleanSeconds = snapshot.priorCleanSeconds
        bestStreakSeconds = snapshot.bestStreakSeconds
        savedBase = snapshot.savedBase
        avoidedBase = snapshot.avoidedBase
        slips = snapshot.slips
        notificationsEnabled = snapshot.notificationsEnabled
        unlockedRaw = snapshot.unlockedRaw
    }
}

struct PlanSnapshot {
    let quitDate: Date
    let productRaw: String
    let unitsPerDay: Double
    let pricePerPackage: Double
    let unitsPerPackage: Double
    let currencyRaw: String
    let priorCleanSeconds: Double
    let bestStreakSeconds: Double
    let savedBase: Double
    let avoidedBase: Double
    let slips: Int
    let notificationsEnabled: Bool
    let unlockedRaw: String
}

struct PlanDraft {
    var product: ProductKind
    var quitDate: Date
    var units: Double
    var price: Double
    var pack: Double
    var currency: CurrencyCode
    var notifications: Bool

    init(plan: UserPlan) {
        product = plan.product
        quitDate = plan.quitDate
        units = plan.product.isPerWeek ? plan.unitsPerDay * 7 : plan.unitsPerDay
        price = plan.pricePerPackage
        pack = plan.unitsPerPackage
        currency = plan.currency
        notifications = plan.notificationsEnabled
    }

    init(product: ProductKind = .cigarettes, currency: CurrencyCode = .RUB) {
        self.product = product
        self.quitDate = .now
        self.units = product.defaults.units
        self.price = product.defaults.price
        self.pack = product.defaults.pack
        self.currency = currency
        self.notifications = true
    }

    mutating func applyDefaults(for product: ProductKind) {
        self.product = product
        units = product.defaults.units
        price = product.defaults.price
        pack = product.defaults.pack
    }

    var unitsPerDay: Double {
        product.isPerWeek ? max(0.01, units) / 7 : max(0.01, units)
    }

    var unitsPerPackage: Double {
        product.isPerWeek ? 1 : max(1, pack)
    }

    var calculatedCostPerDay: Double {
        if product.isPerWeek {
            return max(0, price) * (max(0, units) / 7)
        }
        return max(0, price) / max(1, pack) * max(0, units)
    }

    var isValidMoney: Bool {
        units > 0 && price > 0 && (product.packLabel == nil || pack >= 1)
    }
}
