//
//  KitoDateFormatting.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

public enum KitoDateFormatting {
    /// "2 minutes ago" / "in 3 hours" — the format order-tracking updates
    /// and activity feeds want, without hand-rolling a relative calculation.
    public static func relative(_ date: Date) -> String {
        date.formatted(.relative(presentation: .named))
    }

    /// "2 minutes ago" measured from `reference` instead of now — for previews and tests.
    public static func relative(_ date: Date, to reference: Date, unitsStyle: RelativeDateTimeFormatter.UnitsStyle = .full) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = unitsStyle
        return formatter.localizedString(for: date, relativeTo: reference)
    }

    /// "now", "5m", "3h", "2d", "3w", then "Sep 21" — the tight timestamp chat lists and
    /// notification rows use.
    public static func abbreviated(_ date: Date, now: Date = Date()) -> String {
        let seconds = now.timeIntervalSince(date)
        guard seconds >= 0 else { return shortTime(date) }
        switch seconds {
        case ..<60: return "now"
        case ..<3_600: return "\(Int(seconds / 60))m"
        case ..<86_400: return "\(Int(seconds / 3_600))h"
        case ..<604_800: return "\(Int(seconds / 86_400))d"
        case ..<2_419_200: return "\(Int(seconds / 604_800))w"
        default: return date.formatted(.dateTime.month(.abbreviated).day())
        }
    }

    /// "Today", "Yesterday", "Tomorrow", a weekday within the week either side, otherwise a
    /// medium date — the header above a day's transactions or messages.
    public static func dayLabel(_ date: Date, now: Date = Date(), calendar: Calendar = .current) -> String {
        if calendar.isDate(date, inSameDayAs: now) { return "Today" }
        let startOfDate = calendar.startOfDay(for: date)
        let startOfNow = calendar.startOfDay(for: now)
        let days = calendar.dateComponents([.day], from: startOfNow, to: startOfDate).day ?? 0
        switch days {
        case -1: return "Yesterday"
        case 1: return "Tomorrow"
        case -6...6: return date.formatted(.dateTime.weekday(.wide))
        default: return mediumDate(date)
        }
    }

    /// "9:00 – 10:30 AM" — a booking slot or delivery window.
    public static func timeRange(_ start: Date, _ end: Date) -> String {
        guard end > start else { return shortTime(start) }
        return (start..<end).formatted(.interval.hour().minute())
    }

    /// "Good morning" / "Good afternoon" / "Good evening" for a home-screen greeting.
    public static func greeting(for date: Date = Date(), calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    public static func shortTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }

    public static func mediumDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    public static func full(_ date: Date) -> String {
        date.formatted(date: .long, time: .shortened)
    }
}

public enum KitoDurationFormatting {
    /// "45s", "12m 5s", "1h 5m", "2d 3h" — the two largest non-zero units.
    public static func short(_ seconds: TimeInterval) -> String {
        let total = Int(abs(seconds).rounded())
        let sign = seconds < 0 ? "-" : ""
        let parts: [(Int, String)] = [
            (total / 86_400, "d"),
            ((total % 86_400) / 3_600, "h"),
            ((total % 3_600) / 60, "m"),
            (total % 60, "s"),
        ]
        guard let first = parts.firstIndex(where: { $0.0 > 0 }) else { return "0s" }
        let shown = parts[first...].prefix(2).filter { $0.0 > 0 }
        return sign + shown.map { "\($0.0)\($0.1)" }.joined(separator: " ")
    }

    /// "4:05" / "1:02:09" — a stopwatch, a voice note length, a track position.
    public static func clock(_ seconds: TimeInterval) -> String {
        let total = Int(abs(seconds).rounded(.down))
        let hours = total / 3_600
        let minutes = (total % 3_600) / 60
        let secs = total % 60
        let sign = seconds < 0 ? "-" : ""
        return hours > 0
            ? sign + String(format: "%d:%02d:%02d", hours, minutes, secs)
            : sign + String(format: "%d:%02d", minutes, secs)
    }

    /// "1 hour, 5 minutes" — spelled out, localized, for VoiceOver and long-form copy.
    public static func spelledOut(_ seconds: TimeInterval, maximumUnits: Int = 2) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = maximumUnits
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        return formatter.string(from: abs(seconds)) ?? short(seconds)
    }
}

public enum KitoFileSizeFormatting {
    /// "1.2 MB" / "845 KB" — a download, an attachment, a cache size.
    public static func string(bytes: Int64, style: ByteCountFormatter.CountStyle = .file) -> String {
        ByteCountFormatter.string(fromByteCount: bytes, countStyle: style)
    }

    /// "1.2 MB of 4.5 MB" — a download in progress.
    public static func progress(received: Int64, total: Int64) -> String {
        "\(string(bytes: received)) of \(string(bytes: total))"
    }
}

/// Metric or imperial distances.
public enum KitoDistanceSystem: Sendable, CaseIterable {
    case metric
    case imperial
}

public enum KitoDistanceFormatting {
    /// "850 m", "1.2 km", "12 km" — or "320 ft", "0.5 mi", "12 mi". One decimal below 10, whole
    /// numbers above, the way delivery and ride apps show it.
    public static func string(meters: Double, system: KitoDistanceSystem = .metric) -> String {
        let value = max(meters, 0)
        switch system {
        case .metric:
            if value < 1_000 { return "\(Int(roundedTo(value, step: value < 100 ? 5 : 10))) m" }
            return "\(oneDecimal(value / 1_000)) km"
        case .imperial:
            let feet = value * 3.28084
            if feet < 1_000 { return "\(Int(roundedTo(feet, step: 10))) ft" }
            return "\(oneDecimal(value / 1_609.344)) mi"
        }
    }

    private static func roundedTo(_ value: Double, step: Double) -> Double {
        (value / step).rounded() * step
    }

    private static func oneDecimal(_ value: Double) -> String {
        if value >= 10 { return String(format: "%.0f", value.rounded()) }
        let text = String(format: "%.1f", value)
        return text.hasSuffix(".0") ? String(text.dropLast(2)) : text
    }
}
