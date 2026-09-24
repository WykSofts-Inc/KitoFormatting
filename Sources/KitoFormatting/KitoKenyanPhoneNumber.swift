//
//  KitoKenyanPhoneNumber.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import Foundation

/// The mobile network a Kenyan number was issued on. Best-effort from the number's prefix:
/// numbers can be ported between networks, so never use this to decide where money goes.
public enum KitoKenyanCarrier: String, Sendable, CaseIterable {
    case safaricom
    case airtel
    case telkom
    case unknown

    public var displayName: String {
        switch self {
        case .safaricom: return "Safaricom"
        case .airtel: return "Airtel"
        case .telkom: return "Telkom"
        case .unknown: return "Other network"
        }
    }

    /// The mobile-money wallet usually tied to this network.
    public var walletName: String? {
        switch self {
        case .safaricom: return "M-Pesa"
        case .airtel: return "Airtel Money"
        case .telkom: return "T-Kash"
        case .unknown: return nil
        }
    }
}

/// A Kenyan mobile number, parsed from however the user typed it — "0712 345 678",
/// "712345678", "+254 712 345 678", "254712345678" — and printable every common way.
public struct KitoKenyanPhoneNumber: Equatable, Hashable, Sendable {
    /// The nine digits after the country code, e.g. "712345678".
    public let nationalNumber: String

    /// `nil` unless `raw` is a nine-digit mobile number starting 7 or 1.
    public init?(_ raw: String) {
        var digits = raw.filter(\.isNumber)
        if digits.hasPrefix("254"), digits.count == 12 {
            digits.removeFirst(3)
        } else if digits.hasPrefix("0"), digits.count == 10 {
            digits.removeFirst()
        }
        guard digits.count == 9, let first = digits.first, first == "7" || first == "1" else { return nil }
        nationalNumber = digits
    }

    /// "+254712345678" — for APIs and `tel:` links.
    public var e164: String { "+254" + nationalNumber }

    /// "+254 712 345 678".
    public var international: String { "+254 " + Self.group(nationalNumber, [3, 3, 3]) }

    /// "0712 345 678" — how Kenyans write it.
    public var local: String { Self.group("0" + nationalNumber, [4, 3, 3]) }

    /// "+254 7•• ••• 678" — for confirmation screens.
    public var masked: String {
        let chars = Array(nationalNumber)
        let hidden = chars.enumerated().map { index, char in (1...5).contains(index) ? "•" : String(char) }.joined()
        return "+254 " + Self.group(hidden, [3, 3, 3])
    }

    public var carrier: KitoKenyanCarrier {
        guard let prefix = Int(nationalNumber.prefix(3)) else { return .unknown }
        switch prefix {
        case 700...729, 740...748, 757...759, 768...769, 790...799, 110...115: return .safaricom
        case 730...739, 750...756, 762, 780...789, 100...102: return .airtel
        case 770...779: return .telkom
        default: return .unknown
        }
    }

    /// A `tel:` URL for a call button.
    public var callURL: URL? { URL(string: "tel:\(e164)") }

    static func group(_ text: String, _ sizes: [Int]) -> String {
        var groups: [String] = []
        var rest = Substring(text)
        for size in sizes where !rest.isEmpty {
            groups.append(String(rest.prefix(size)))
            rest = rest.dropFirst(size)
        }
        if !rest.isEmpty { groups.append(String(rest)) }
        return groups.joined(separator: " ")
    }
}

public enum KitoPhoneFormatting {
    /// Formats a Kenyan number while it's being typed: "0712 345 678" for local input, or
    /// "+254 712 345 678" once the user starts with "+" or "254". Extra digits are dropped.
    public static func kenyanAsYouType(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber)
        let isInternational = raw.trimmingCharacters(in: .whitespaces).hasPrefix("+") || digits.hasPrefix("254")
        if isInternational {
            let national = String(digits.dropFirst(min(3, digits.count)).prefix(9))
            let head = digits.count >= 3 ? "+254" : "+" + digits
            return national.isEmpty ? head : head + " " + KitoKenyanPhoneNumber.group(national, [3, 3, 3])
        }
        return KitoKenyanPhoneNumber.group(String(digits.prefix(10)), [4, 3, 3])
    }
}
