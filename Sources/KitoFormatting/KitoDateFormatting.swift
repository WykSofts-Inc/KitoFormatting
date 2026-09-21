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
