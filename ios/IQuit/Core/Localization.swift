import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case ru
    case en

    var id: String { rawValue }

    var locale: Locale {
        Locale(identifier: self == .ru ? "ru_RU" : "en_US")
    }

    var displayName: String {
        self == .ru ? "Русский" : "English"
    }

    var bundle: Bundle {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let localized = Bundle(path: path) else {
            return .main
        }
        return localized
    }

    static var systemDefault: AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("ru") ? .ru : .en
    }
}

enum L10n {
    static func t(_ key: String, language: AppLanguage) -> String {
        NSLocalizedString(key, tableName: nil, bundle: language.bundle, value: key, comment: "")
    }
}

enum Plural {
    static func word(_ value: Double, base: String, language: AppLanguage) -> String {
        let number = abs(Int(value.rounded()))
        if language == .en {
            return L10n.t(base + (number == 1 ? "" : "s"), language: language)
        }
        let last = number % 10
        let lastTwo = number % 100
        if last == 1 && lastTwo != 11 {
            return L10n.t(base, language: language)
        }
        if (2...4).contains(last) && !(12...14).contains(lastTwo) {
            return L10n.t(base + "s", language: language)
        }
        return L10n.t(base + "sMany", language: language)
    }

    static func days(_ value: Double, language: AppLanguage) -> String {
        word(value, base: "day", language: language)
    }

    static func unit(_ value: Double, product: ProductKind, language: AppLanguage) -> String {
        let forms = product.unitForms
        let number = abs(Int(value.rounded()))
        if language == .en {
            return number == 1 ? forms.enOne : forms.enMany
        }
        let last = number % 10
        let lastTwo = number % 100
        if last == 1 && lastTwo != 11 { return forms.ruOne }
        if (2...4).contains(last) && !(12...14).contains(lastTwo) { return forms.ruFew }
        return forms.ruMany
    }
}
