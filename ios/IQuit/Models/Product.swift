import Foundation

struct UnitForms {
    let ruOne: String
    let ruFew: String
    let ruMany: String
    let enOne: String
    let enMany: String
}

struct ProductDefaults {
    let units: Double
    let price: Double
    let pack: Double
}

enum ProductKind: String, CaseIterable, Identifiable, Codable {
    case cigarettes
    case vape
    case iqos
    case hookah
    case snus

    var id: String { rawValue }

    var name: LocalizedText {
        switch self {
        case .cigarettes: return LocalizedText(ru: "Сигареты", en: "Cigarettes")
        case .vape: return LocalizedText(ru: "Вейп", en: "Vape")
        case .iqos: return LocalizedText(ru: "IQOS / стики", en: "IQOS / heated")
        case .hookah: return LocalizedText(ru: "Кальян", en: "Hookah")
        case .snus: return LocalizedText(ru: "Снюс / паучи", en: "Snus / pouches")
        }
    }

    var unitLabel: LocalizedText {
        switch self {
        case .cigarettes: return LocalizedText(ru: "сигарет в день", en: "cigarettes per day")
        case .vape: return LocalizedText(ru: "мл в день", en: "ml per day")
        case .iqos: return LocalizedText(ru: "стиков в день", en: "sticks per day")
        case .hookah: return LocalizedText(ru: "сессий в неделю", en: "sessions per week")
        case .snus: return LocalizedText(ru: "паучей в день", en: "pouches per day")
        }
    }

    var unitShort: LocalizedText {
        switch self {
        case .cigarettes: return LocalizedText(ru: "сигарет", en: "cigarettes")
        case .vape: return LocalizedText(ru: "мл", en: "ml")
        case .iqos: return LocalizedText(ru: "стиков", en: "sticks")
        case .hookah: return LocalizedText(ru: "сессий", en: "sessions")
        case .snus: return LocalizedText(ru: "паучей", en: "pouches")
        }
    }

    var unitForms: UnitForms {
        switch self {
        case .cigarettes:
            return UnitForms(ruOne: "сигарета", ruFew: "сигареты", ruMany: "сигарет", enOne: "cigarette", enMany: "cigarettes")
        case .vape:
            return UnitForms(ruOne: "мл", ruFew: "мл", ruMany: "мл", enOne: "ml", enMany: "ml")
        case .iqos:
            return UnitForms(ruOne: "стик", ruFew: "стика", ruMany: "стиков", enOne: "stick", enMany: "sticks")
        case .hookah:
            return UnitForms(ruOne: "сессия", ruFew: "сессии", ruMany: "сессий", enOne: "session", enMany: "sessions")
        case .snus:
            return UnitForms(ruOne: "пауч", ruFew: "пауча", ruMany: "паучей", enOne: "pouch", enMany: "pouches")
        }
    }

    var priceLabel: LocalizedText {
        switch self {
        case .cigarettes: return LocalizedText(ru: "Цена пачки", en: "Pack price")
        case .vape: return LocalizedText(ru: "Цена бутылки", en: "Bottle price")
        case .iqos: return LocalizedText(ru: "Цена пачки", en: "Pack price")
        case .hookah: return LocalizedText(ru: "Цена сессии", en: "Cost per session")
        case .snus: return LocalizedText(ru: "Цена банки", en: "Can price")
        }
    }

    var packLabel: LocalizedText? {
        switch self {
        case .cigarettes: return LocalizedText(ru: "Сигарет в пачке", en: "Cigarettes per pack")
        case .vape: return LocalizedText(ru: "Мл в бутылке", en: "Ml per bottle")
        case .iqos: return LocalizedText(ru: "Стиков в пачке", en: "Sticks per pack")
        case .hookah: return nil
        case .snus: return LocalizedText(ru: "Паучей в банке", en: "Pouches per can")
        }
    }

    var defaults: ProductDefaults {
        switch self {
        case .cigarettes: return ProductDefaults(units: 20, price: 250, pack: 20)
        case .vape: return ProductDefaults(units: 3, price: 900, pack: 30)
        case .iqos: return ProductDefaults(units: 15, price: 200, pack: 20)
        case .hookah: return ProductDefaults(units: 3, price: 500, pack: 1)
        case .snus: return ProductDefaults(units: 8, price: 450, pack: 20)
        }
    }

    var isPerWeek: Bool { self == .hookah }

    var icon: String {
        switch self {
        case .cigarettes: return "capsule.fill"
        case .vape: return "cloud.fill"
        case .iqos: return "rectangle.portrait.fill"
        case .hookah: return "drop.fill"
        case .snus: return "circle.grid.3x3.fill"
        }
    }
}

struct LocalizedText: Hashable {
    let ru: String
    let en: String

    func value(_ language: AppLanguage) -> String {
        language == .ru ? ru : en
    }
}
