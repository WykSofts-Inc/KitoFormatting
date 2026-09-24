//
//  KitoMoneyFormatting.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

/// Whether an amount leads with the ISO code ("KES 1,250") or the symbol ("KSh 1,250").
public enum KitoCurrencyDisplay: Sendable, CaseIterable {
    case code
    case symbol
}

/// When cents are shown.
public enum KitoCents: Sendable, CaseIterable {
    /// Cents only when there are some: "KES 1,250" but "KES 1,250.50".
    case auto
    /// Always the currency's minor units: "KES 1,250.00".
    case always
    /// Rounded to whole units: "KES 1,251".
    case never
}

public extension KitoCurrency {
    /// Digits after the decimal point in everyday use (ISO 4217 minor units).
    var minorUnits: Int {
        switch self {
        case .ugx: return 0
        default: return 2
        }
    }

    /// A flag for pickers and chips.
    var flag: String {
        switch self {
        case .kes: return "🇰🇪"
        case .usd: return "🇺🇸"
        case .eur: return "🇪🇺"
        case .gbp: return "🇬🇧"
        case .ngn: return "🇳🇬"
        case .zar: return "🇿🇦"
        case .ugx: return "🇺🇬"
        case .tzs: return "🇹🇿"
        }
    }

    /// The prefix placed before an amount, with a space after lettered prefixes ("KES ", "KSh ")
    /// and none after glyphs ("$", "€").
    func prefix(_ display: KitoCurrencyDisplay) -> String {
        let text = display == .code ? rawValue : symbol
        return text.count > 1 ? text + " " : text
    }
}

/// Amounts that read the same on every device — fixed "1,234.56" grouping, so receipts, carts
/// and screenshots don't change with the phone's region. Use `Decimal.kitoFormatted(currency:)`
/// when you want the user's own locale instead.
public enum KitoMoneyFormatting {
    /// "KES 1,250.50", "KSh 1,250", "$42".
    public static func string(
        _ amount: Decimal,
        currency: KitoCurrency,
        display: KitoCurrencyDisplay = .code,
        cents: KitoCents = .auto
    ) -> String {
        let sign = amount < 0 ? "-" : ""
        return sign + currency.prefix(display) + digits(abs(amount), currency: currency, cents: cents)
    }

    /// "+KES 500" / "−KES 1,200" — for transaction lists and balance changes.
    public static func signed(
        _ amount: Decimal,
        currency: KitoCurrency,
        display: KitoCurrencyDisplay = .code,
        cents: KitoCents = .auto
    ) -> String {
        let sign = amount > 0 ? "+" : (amount < 0 ? "\u{2212}" : "")
        return sign + currency.prefix(display) + digits(abs(amount), currency: currency, cents: cents)
    }

    /// "KES 1.2M", "$3.4K" — for stat tiles and chart labels.
    public static func compact(_ amount: Decimal, currency: KitoCurrency, display: KitoCurrencyDisplay = .code) -> String {
        let value = (amount as NSDecimalNumber).doubleValue
        let sign = value < 0 ? "-" : ""
        return sign + currency.prefix(display) + KitoNumberFormatting.compact(abs(value))
    }

    /// Just the number part: "1,250.50".
    public static func digits(_ amount: Decimal, currency: KitoCurrency, cents: KitoCents = .auto) -> String {
        let fraction: Int
        switch cents {
        case .always: fraction = currency.minorUnits
        case .never: fraction = 0
        case .auto:
            var whole = amount
            var rounded = Decimal()
            NSDecimalRound(&rounded, &whole, 0, .plain)
            fraction = rounded == amount ? 0 : currency.minorUnits
        }
        return KitoNumberFormatting.groupedDecimal(amount, fractionDigits: fraction)
    }
}

public extension Decimal {
    /// "KES 1,250.50" — device-independent; see `KitoMoneyFormatting`.
    func kitoAmount(in currency: KitoCurrency, display: KitoCurrencyDisplay = .code, cents: KitoCents = .auto) -> String {
        KitoMoneyFormatting.string(self, currency: currency, display: display, cents: cents)
    }

    /// "KES 1.2M" — device-independent compact amount.
    func kitoCompactAmount(in currency: KitoCurrency, display: KitoCurrencyDisplay = .code) -> String {
        KitoMoneyFormatting.compact(self, currency: currency, display: display)
    }
}
