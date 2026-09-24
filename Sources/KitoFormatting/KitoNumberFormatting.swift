//
//  KitoNumberFormatting.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

public enum KitoNumberFormatting {
    /// "1.2K" / "3.4M" / "2.1B" — for space-constrained UI (list rows, chart
    /// axis labels, stat tiles) where a full formatted number would wrap or
    /// truncate. Falls back to the plain integer below 1,000.
    public static func compact(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        let absValue = abs(value)
        switch absValue {
        case 1_000_000_000...:
            return "\(sign)\(trimmed(absValue / 1_000_000_000))B"
        case 1_000_000...:
            return "\(sign)\(trimmed(absValue / 1_000_000))M"
        case 1_000...:
            return "\(sign)\(trimmed(absValue / 1_000))K"
        default:
            return "\(sign)\(trimmed(absValue))"
        }
    }

    public static func percent(_ value: Double, fractionDigits: Int = 0, locale: Locale = .current) -> String {
        value.formatted(.percent.precision(.fractionLength(fractionDigits)).locale(locale))
    }

    /// "+12.5%" / "−3.2%" / "0.0%" from a fraction (0.125 → "+12.5%") — the sign is always
    /// shown so a change reads as a change. Uses a true minus sign (U+2212). Digits, decimal
    /// separator and percent sign follow `locale`.
    public static func signedPercent(_ fraction: Double, fractionDigits: Int = 1, locale: Locale = .current) -> String {
        let digits = max(fractionDigits, 0)
        let scale = pow(10, Double(digits))
        let isZero = (abs(fraction) * 100 * scale).rounded() == 0
        let magnitude = abs(fraction).formatted(.percent.precision(.fractionLength(digits)).locale(locale))
        let sign = isZero ? "" : (fraction > 0 ? "+" : "\u{2212}")
        return "\(sign)\(magnitude)"
    }

    /// "1,250,000" / "1,250.50" — fixed comma grouping and a dot for decimals, whatever the
    /// device region.
    public static func grouped(_ value: Double, fractionDigits: Int = 0) -> String {
        groupedDecimal(Decimal(value), fractionDigits: fractionDigits)
    }

    /// Decimal variant of `grouped(_:fractionDigits:)` — no binary floating-point drift.
    static func groupedDecimal(_ value: Decimal, fractionDigits: Int) -> String {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.decimalSeparator = "."
        formatter.roundingMode = .halfUp
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: value as NSDecimalNumber) ?? "\(value)"
    }

    /// "1st", "2nd", "3rd", "11th", "22nd" — English ordinals for ranks and streaks.
    public static func ordinal(_ value: Int) -> String {
        let tens = abs(value) % 100
        let ones = abs(value) % 10
        let suffix: String
        if (11...13).contains(tens) {
            suffix = "th"
        } else {
            switch ones {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        return "\(value)\(suffix)"
    }

    private static func trimmed(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}

/// Which way a change went — drives arrows and colours in `KitoChangeBadge`.
public enum KitoTrend: Sendable, Equatable {
    case up
    case down
    case flat

    /// Anything within `tolerance` of zero counts as flat, so "+0.0%" never shows a green arrow.
    public init(_ change: Double, tolerance: Double = 0.0005) {
        if change > tolerance { self = .up } else if change < -tolerance { self = .down } else { self = .flat }
    }

    public var systemImage: String {
        switch self {
        // Forward variants mirror in right-to-left layouts, where time runs leftwards.
        case .up: return "arrow.up.forward"
        case .down: return "arrow.down.forward"
        case .flat: return "arrow.forward"
        }
    }

    public var accessibilityLabel: String {
        switch self {
        case .up: return "Up"
        case .down: return "Down"
        case .flat: return "Unchanged"
        }
    }
}
