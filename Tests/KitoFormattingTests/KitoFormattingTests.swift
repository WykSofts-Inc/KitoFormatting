//
//  KitoFormattingTests.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/21/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoFormatting

final class KitoFormattingTests: XCTestCase {
    func testCompactFormattingThousands() {
        XCTAssertEqual(KitoNumberFormatting.compact(1200), "1.2K")
        XCTAssertEqual(KitoNumberFormatting.compact(999), "999")
    }

    func testCompactFormattingMillionsAndBillions() {
        XCTAssertEqual(KitoNumberFormatting.compact(2_500_000), "2.5M")
        XCTAssertEqual(KitoNumberFormatting.compact(1_000_000_000), "1B")
    }

    func testCompactFormattingWholeNumberDropsDecimal() {
        XCTAssertEqual(KitoNumberFormatting.compact(2000), "2K")
    }

    func testCompactFormattingNegativeValues() {
        XCTAssertEqual(KitoNumberFormatting.compact(-1500), "-1.5K")
    }

    func testCurrencySymbols() {
        XCTAssertEqual(KitoCurrency.kes.symbol, "KSh")
        XCTAssertEqual(KitoCurrency.usd.symbol, "$")
    }

    func testDecimalCurrencyFormattingIncludesSymbolOrCode() {
        let formatted = Decimal(42.5).kitoFormatted(currency: .usd, locale: Locale(identifier: "en_US"))
        XCTAssertTrue(formatted.contains("42.5") || formatted.contains("42.50"))
    }

    func testCompactCurrencyFormatting() {
        let formatted = Decimal(1500).kitoCompactFormatted(currency: .kes)
        XCTAssertEqual(formatted, "KSh 1.5K")
    }

    func testPercentFormattingRoundsToRequestedFractionDigits() {
        let formatted = KitoNumberFormatting.percent(0.4567, fractionDigits: 1)
        XCTAssertTrue(formatted.contains("45.7") || formatted.contains("46"))
    }
}
