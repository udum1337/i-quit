import Foundation

enum CurrencyCode: String, CaseIterable, Identifiable, Codable {
    case RUB
    case USD
    case EUR
    case KZT
    case UAH
    case BYN
    case GBP
    case TRY
    case CNY

    var id: String { rawValue }

    var symbol: String {
        switch self {
        case .RUB: return "₽"
        case .USD: return "$"
        case .EUR: return "€"
        case .KZT: return "₸"
        case .UAH: return "₴"
        case .BYN: return "Br"
        case .GBP: return "£"
        case .TRY: return "₺"
        case .CNY: return "¥"
        }
    }

    var label: LocalizedText {
        switch self {
        case .RUB: return LocalizedText(ru: "Российский рубль", en: "Russian ruble")
        case .USD: return LocalizedText(ru: "Доллар США", en: "US dollar")
        case .EUR: return LocalizedText(ru: "Евро", en: "Euro")
        case .KZT: return LocalizedText(ru: "Казахстанский тенге", en: "Kazakhstani tenge")
        case .UAH: return LocalizedText(ru: "Украинская гривна", en: "Ukrainian hryvnia")
        case .BYN: return LocalizedText(ru: "Белорусский рубль", en: "Belarusian ruble")
        case .GBP: return LocalizedText(ru: "Фунт стерлингов", en: "British pound")
        case .TRY: return LocalizedText(ru: "Турецкая лира", en: "Turkish lira")
        case .CNY: return LocalizedText(ru: "Китайский юань", en: "Chinese yuan")
        }
    }
}
