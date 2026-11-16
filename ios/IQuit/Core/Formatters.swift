import Foundation

enum Format {
    private static var numberFormatters: [String: NumberFormatter] = [:]
    private static var dateFormatters: [String: DateFormatter] = [:]

    static func number(_ value: Double, language: AppLanguage, digits: Int = 0) -> String {
        let key = "\(language.rawValue)-\(digits)"
        let formatter: NumberFormatter
        if let cached = numberFormatters[key] {
            formatter = cached
        } else {
            let created = NumberFormatter()
            created.locale = language.locale
            created.numberStyle = .decimal
            created.maximumFractionDigits = digits
            created.minimumFractionDigits = 0
            created.usesGroupingSeparator = true
            numberFormatters[key] = created
            formatter = created
        }
        return formatter.string(from: NSNumber(value: value)) ?? String(Int(value))
    }

    static func money(_ value: Double, currency: CurrencyCode, language: AppLanguage) -> String {
        let amount = number(max(0, value.rounded(.down)), language: language, digits: 0)
        if language == .en {
            return currency.symbol.count > 1 ? "\(currency.symbol) \(amount)" : "\(currency.symbol)\(amount)"
        }
        return "\(amount) \(currency.symbol)"
    }

    static func currencyValue(_ currency: CurrencyCode) -> String {
        "\(currency.symbol) \(currency.rawValue)"
    }

    static func hms(_ seconds: TimeInterval) -> String {
        let total = max(0, Int(seconds))
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }

    static func durationShort(_ seconds: TimeInterval, language: AppLanguage) -> String {
        let total = max(0, Int(seconds.rounded()))
        let days = total / 86_400
        let hours = (total % 86_400) / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60
        let ru = language == .ru
        if days > 0 { return "\(days)\(ru ? " д " : "d ")\(hours)\(ru ? " ч" : "h")" }
        if hours > 0 { return "\(hours)\(ru ? " ч " : "h ")\(minutes)\(ru ? " мин" : "m")" }
        if minutes > 0 { return "\(minutes)\(ru ? " мин" : "m")" }
        return "\(secs)\(ru ? " сек" : "s")"
    }

    static func countdown(_ remaining: TimeInterval, language: AppLanguage) -> String {
        if remaining <= 0 {
            return L10n.t("allDone", language: language)
        }
        return L10n.t("nextIn", language: language) + " " + durationShort(remaining, language: language)
    }

    static func days(_ value: Double, language: AppLanguage) -> String {
        "\(Int(max(0, value).rounded(.down))) \(Plural.days(value, language: language))"
    }

    static func dateLong(_ date: Date, language: AppLanguage) -> String {
        dateString(date, template: "EEEE d MMMM", language: language)
    }

    static func dateTime(_ date: Date, language: AppLanguage) -> String {
        dateString(date, template: "d MMM yyyy HH:mm", language: language)
    }

    private static func dateString(_ date: Date, template: String, language: AppLanguage) -> String {
        let key = "\(language.rawValue)-\(template)"
        let formatter: DateFormatter
        if let cached = dateFormatters[key] {
            formatter = cached
        } else {
            let created = DateFormatter()
            created.locale = language.locale
            created.setLocalizedDateFormatFromTemplate(template)
            dateFormatters[key] = created
            formatter = created
        }
        return formatter.string(from: date)
    }
}
