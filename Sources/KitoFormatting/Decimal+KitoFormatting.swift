//
//  Decimal+KitoFormatting.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

public extension Decimal {
    /// Locale-aware currency formatting via `KitoCurrency` — e.g.
    /// `42.kitoFormatted(currency: .kes)` → "KSh 42.00" under a Kenyan locale.
    func kitoFormatted(currency: KitoCurrency, locale: Locale = .current) -> String {
        self.formatted(.currency(code: currency.rawValue).locale(locale))
    }

    /// Any raw ISO 4217 code not covered by `KitoCurrency`.
    func kitoFormatted(currencyCode: String, locale: Locale = .current) -> String {
        self.formatted(.currency(code: currencyCode).locale(locale))
    }

    /// "KSh 1.2K" — compact currency for list rows and stat tiles.
    func kitoCompactFormatted(currency: KitoCurrency) -> String {
        let value = (self as NSDecimalNumber).doubleValue
        return "\(currency.symbol) \(KitoNumberFormatting.compact(value))"
    }
}
