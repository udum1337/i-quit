import Foundation

struct WidgetMilestone: Codable, Identifiable {
    let id: String
    let at: TimeInterval
    let title: String
}

struct WidgetSnapshot: Codable {
    var quitDate: Date
    var bestStreakSeconds: TimeInterval
    var costPerDay: Double
    var savedBase: Double
    var currencySymbol: String
    var languageCode: String
    var statusLabel: String
    var bestLabel: String
    var nextLabel: String
    var savedLabel: String
    var dayOne: String
    var dayFew: String
    var dayMany: String
    var allDoneText: String
    var milestones: [WidgetMilestone]
    var updatedAt: Date

    func elapsed(at date: Date) -> TimeInterval {
        max(0, date.timeIntervalSince(quitDate))
    }

    func currentDays(at date: Date) -> Int {
        Int(elapsed(at: date) / 86_400)
    }

    func bestDays(at date: Date) -> Int {
        Int(max(bestStreakSeconds, elapsed(at: date)) / 86_400)
    }

    func saved(at date: Date) -> Double {
        savedBase + costPerDay * (elapsed(at: date) / 86_400)
    }

    func dayWord(for value: Int) -> String {
        if languageCode == "en" {
            return value == 1 ? dayOne : dayMany
        }
        let last = value % 10
        let lastTwo = value % 100
        if last == 1 && lastTwo != 11 { return dayOne }
        if (2...4).contains(last) && !(12...14).contains(lastTwo) { return dayFew }
        return dayMany
    }

    func currentMilestone(at date: Date) -> WidgetMilestone? {
        let seconds = elapsed(at: date)
        return milestones.last { $0.at <= seconds }
    }

    func nextMilestone(at date: Date) -> WidgetMilestone? {
        let seconds = elapsed(at: date)
        return milestones.first { $0.at > seconds }
    }

    func progress(at date: Date) -> Double {
        let seconds = elapsed(at: date)
        guard let next = nextMilestone(at: date) else { return 1 }
        let start = currentMilestone(at: date)?.at ?? 0
        let span = max(1, next.at - start)
        return min(1, max(0, (seconds - start) / span))
    }

    func moneyText(at date: Date) -> String {
        let value = max(0, saved(at: date).rounded(.down))
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: languageCode == "ru" ? "ru_RU" : "en_US")
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        if languageCode == "en" {
            return currencySymbol.count > 1 ? "\(currencySymbol) \(number)" : "\(currencySymbol)\(number)"
        }
        return "\(number) \(currencySymbol)"
    }

    static var placeholder: WidgetSnapshot {
        WidgetSnapshot(
            quitDate: Date().addingTimeInterval(-12 * 86_400 - 4 * 3_600),
            bestStreakSeconds: 12 * 86_400,
            costPerDay: 250,
            savedBase: 0,
            currencySymbol: "₽",
            languageCode: "ru",
            statusLabel: "без никотина",
            bestLabel: "лучший стрик",
            nextLabel: "Следующая веха",
            savedLabel: "Сэкономлено",
            dayOne: "день",
            dayFew: "дня",
            dayMany: "дней",
            allDoneText: "Все вехи пройдены",
            milestones: [
                WidgetMilestone(id: "m20m", at: 20 * 60, title: "Пульс приходит в норму"),
                WidgetMilestone(id: "m8h", at: 8 * 3_600, title: "Кислород возвращается"),
                WidgetMilestone(id: "m12_24h", at: 12 * 3_600, title: "Никотин покидает кровь"),
                WidgetMilestone(id: "m48h", at: 48 * 3_600, title: "Лёгкие начинают очищаться"),
                WidgetMilestone(id: "m72h", at: 72 * 3_600, title: "Дышать легче"),
                WidgetMilestone(id: "m2w", at: 14 * 86_400, title: "Кровообращение улучшается")
            ],
            updatedAt: Date()
        )
    }
}

enum WidgetStore {
    static let appGroup = "group.com.iquit.ios"
    static let key = "widgetSnapshot"

    static func save(_ snapshot: WidgetSnapshot) {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        defaults.set(data, forKey: key)
    }

    static func load() -> WidgetSnapshot? {
        guard let defaults = UserDefaults(suiteName: appGroup),
              let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(WidgetSnapshot.self, from: data)
    }

    static func clear() {
        guard let defaults = UserDefaults(suiteName: appGroup) else { return }
        defaults.removeObject(forKey: key)
    }
}
