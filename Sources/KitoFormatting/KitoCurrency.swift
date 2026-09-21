//
//  KitoCurrency.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

/// The currencies Kito's own sample flows use most (built for a
/// Kenya-weighted, M-Pesa-adjacent product) plus common majors. Not
/// exhaustive — `Decimal.kitoFormatted(currencyCode:)` accepts any raw ISO
/// 4217 code, `KitoCurrency` just gives named, autocompletable cases with a
/// symbol for compact display.
public enum KitoCurrency: String, CaseIterable, Sendable {
    case kes = "KES"
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"
    case ngn = "NGN"
    case zar = "ZAR"
    case ugx = "UGX"
    case tzs = "TZS"

    public var symbol: String {
        switch self {
        case .kes: return "KSh"
        case .usd: return "$"
        case .eur: return "€"
        case .gbp: return "£"
        case .ngn: return "₦"
        case .zar: return "R"
        case .ugx: return "USh"
        case .tzs: return "TSh"
        }
    }
}
