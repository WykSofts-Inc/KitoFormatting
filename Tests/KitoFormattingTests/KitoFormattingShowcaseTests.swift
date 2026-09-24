//
//  KitoFormattingShowcaseTests.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import XCTest
@testable import KitoFormatting

final class KitoFormattingShowcaseTests: XCTestCase {
    // MARK: Money

    func testAmountUsesCodeAndTrimsWholeCents() {
        XCTAssertEqual(Decimal(1250).kitoAmount(in: .kes), "KES 1,250")
        XCTAssertEqual(Decimal(string: "1250.5")!.kitoAmount(in: .kes), "KES 1,250.50")
    }

    func testAmountSymbolSpacing() {
        XCTAssertEqual(Decimal(1250).kitoAmount(in: .kes, display: .symbol), "KSh 1,250")
        XCTAssertEqual(Decimal(42).kitoAmount(in: .usd, display: .symbol, cents: .always), "$42.00")
    }

    func testAmountNeverShowsCentsForUgandanShilling() {
        XCTAssertEqual(Decimal(string: "15000.4")!.kitoAmount(in: .ugx), "UGX 15,000")
    }

    func testSignedAmount() {
        XCTAssertEqual(KitoMoneyFormatting.signed(500, currency: .kes), "+KES 500")
        XCTAssertEqual(KitoMoneyFormatting.signed(-1200, currency: .kes), "\u{2212}KES 1,200")
        XCTAssertEqual(KitoMoneyFormatting.signed(0, currency: .kes), "KES 0")
    }

    func testCompactAmount() {
        XCTAssertEqual(Decimal(1_200_000).kitoCompactAmount(in: .kes), "KES 1.2M")
        XCTAssertEqual(Decimal(3_400).kitoCompactAmount(in: .usd, display: .symbol), "$3.4K")
    }

    // MARK: Numbers

    func testSignedPercent() {
        XCTAssertEqual(KitoNumberFormatting.signedPercent(0.125), "+12.5%")
        XCTAssertEqual(KitoNumberFormatting.signedPercent(-0.032), "\u{2212}3.2%")
        XCTAssertEqual(KitoNumberFormatting.signedPercent(0.00001), "0.0%")
    }

    func testTrend() {
        XCTAssertEqual(KitoTrend(0.2), .up)
        XCTAssertEqual(KitoTrend(-0.2), .down)
        XCTAssertEqual(KitoTrend(0.0001), .flat)
    }

    func testGroupedAndOrdinal() {
        XCTAssertEqual(KitoNumberFormatting.grouped(1_250_000), "1,250,000")
        XCTAssertEqual(KitoNumberFormatting.ordinal(1), "1st")
        XCTAssertEqual(KitoNumberFormatting.ordinal(12), "12th")
        XCTAssertEqual(KitoNumberFormatting.ordinal(22), "22nd")
        XCTAssertEqual(KitoNumberFormatting.ordinal(113), "113th")
    }

    // MARK: Durations, distance, size

    func testShortDuration() {
        XCTAssertEqual(KitoDurationFormatting.short(45), "45s")
        XCTAssertEqual(KitoDurationFormatting.short(3_900), "1h 5m")
        XCTAssertEqual(KitoDurationFormatting.short(3_600), "1h")
        XCTAssertEqual(KitoDurationFormatting.short(0), "0s")
        XCTAssertEqual(KitoDurationFormatting.short(183_600), "2d 3h")
    }

    func testClockDuration() {
        XCTAssertEqual(KitoDurationFormatting.clock(245), "4:05")
        XCTAssertEqual(KitoDurationFormatting.clock(3_729), "1:02:09")
    }

    func testDistance() {
        XCTAssertEqual(KitoDistanceFormatting.string(meters: 848), "850 m")
        XCTAssertEqual(KitoDistanceFormatting.string(meters: 1_240), "1.2 km")
        XCTAssertEqual(KitoDistanceFormatting.string(meters: 2_000), "2 km")
        XCTAssertEqual(KitoDistanceFormatting.string(meters: 12_400), "12 km")
        XCTAssertEqual(KitoDistanceFormatting.string(meters: 8_047, system: .imperial), "5 mi")
    }

    func testFileSizeMentionsUnit() {
        XCTAssertTrue(KitoFileSizeFormatting.string(bytes: 1_200_000).contains("MB"))
    }

    // MARK: Dates

    func testAbbreviatedRelative() {
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertEqual(KitoDateFormatting.abbreviated(now.addingTimeInterval(-20), now: now), "now")
        XCTAssertEqual(KitoDateFormatting.abbreviated(now.addingTimeInterval(-300), now: now), "5m")
        XCTAssertEqual(KitoDateFormatting.abbreviated(now.addingTimeInterval(-3 * 3_600), now: now), "3h")
        XCTAssertEqual(KitoDateFormatting.abbreviated(now.addingTimeInterval(-2 * 86_400), now: now), "2d")
    }

    func testDayLabel() {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date(timeIntervalSince1970: 1_800_000_000)
        XCTAssertEqual(KitoDateFormatting.dayLabel(now, now: now, calendar: calendar), "Today")
        XCTAssertEqual(KitoDateFormatting.dayLabel(now.addingTimeInterval(-86_400), now: now, calendar: calendar), "Yesterday")
        XCTAssertEqual(KitoDateFormatting.dayLabel(now.addingTimeInterval(86_400), now: now, calendar: calendar), "Tomorrow")
    }

    // MARK: Phone numbers

    func testKenyanPhoneParsesEveryCommonShape() {
        let expected = "712345678"
        for raw in ["0712345678", "0712 345 678", "712345678", "+254712345678", "254 712 345 678", "+254 (712) 345-678"] {
            XCTAssertEqual(KitoKenyanPhoneNumber(raw)?.nationalNumber, expected, raw)
        }
    }

    func testKenyanPhoneRejectsInvalid() {
        XCTAssertNil(KitoKenyanPhoneNumber("0812345678"))
        XCTAssertNil(KitoKenyanPhoneNumber("07123"))
        XCTAssertNil(KitoKenyanPhoneNumber("+2557123456789"))
    }

    func testKenyanPhoneFormats() throws {
        let phone = try XCTUnwrap(KitoKenyanPhoneNumber("0712345678"))
        XCTAssertEqual(phone.e164, "+254712345678")
        XCTAssertEqual(phone.international, "+254 712 345 678")
        XCTAssertEqual(phone.local, "0712 345 678")
        XCTAssertEqual(phone.masked, "+254 7•• ••• 678")
    }

    func testKenyanCarrier() {
        XCTAssertEqual(KitoKenyanPhoneNumber("0712345678")?.carrier, .safaricom)
        XCTAssertEqual(KitoKenyanPhoneNumber("0733345678")?.carrier, .airtel)
        XCTAssertEqual(KitoKenyanPhoneNumber("0772345678")?.carrier, .telkom)
        XCTAssertEqual(KitoKenyanPhoneNumber("0110345678")?.carrier, .safaricom)
    }

    func testPhoneAsYouType() {
        XCTAssertEqual(KitoPhoneFormatting.kenyanAsYouType("0712"), "0712")
        XCTAssertEqual(KitoPhoneFormatting.kenyanAsYouType("071234"), "0712 34")
        XCTAssertEqual(KitoPhoneFormatting.kenyanAsYouType("0712345678999"), "0712 345 678")
        XCTAssertEqual(KitoPhoneFormatting.kenyanAsYouType("+2547123"), "+254 712 3")
    }
}
