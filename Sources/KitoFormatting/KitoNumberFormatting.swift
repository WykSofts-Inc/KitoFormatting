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

    public static func percent(_ value: Double, fractionDigits: Int = 0) -> String {
        value.formatted(.percent.precision(.fractionLength(fractionDigits)))
    }

    private static func trimmed(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}
