# KitoFormatting

**[Documentation](https://wyksofts-inc.github.io/KitoFormatting/documentation/kitoformatting/)**

Currency (KES, USD, and more), compact number, percent, and date formatting
— locale-aware, built on Foundation's native `FormatStyle` rather than
hand-rolled string math.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoFormatting.git", from: "1.1.0"),
```

## Samples

**Currency:**
```swift
let price = Decimal(1250.50)
Text(price.kitoFormatted(currency: .kes))          // "KSh 1,250.50"
Text(price.kitoCompactFormatted(currency: .kes))   // "KSh 1.3K"
```

**Any ISO 4217 code, not just the built-in cases:**
```swift
Text(price.kitoFormatted(currencyCode: "JPY"))
```

**Compact numbers for stat tiles / chart axes:**
```swift
Text(KitoNumberFormatting.compact(47_200))   // "47.2K"
Text(KitoNumberFormatting.compact(2_100_000)) // "2.1M"
```

**Percent:**
```swift
Text(KitoNumberFormatting.percent(0.847, fractionDigits: 1))   // "84.7%"
```

**Dates:**
```swift
Text(KitoDateFormatting.relative(order.placedAt))   // "2 minutes ago"
Text(KitoDateFormatting.shortTime(delivery.eta))    // "4:32 PM"
Text(KitoDateFormatting.mediumDate(invoice.date))   // "Sep 21, 2026"
```

**Amounts that read the same on every device (1.1):**
```swift
Decimal(1250).kitoAmount(in: .kes)                      // "KES 1,250"
Decimal(1250.5).kitoAmount(in: .kes, display: .symbol)  // "KSh 1,250.50"
Decimal(1_200_000).kitoCompactAmount(in: .kes)          // "KES 1.2M"
KitoMoneyFormatting.signed(-1200, currency: .kes)       // "−KES 1,200"
```

**Changes with sign and colour:**
```swift
KitoNumberFormatting.signedPercent(0.124)   // "+12.4%"
KitoChangeBadge(0.124)                      // green pill with an up arrow
KitoChangeBadge(-0.08, invertsColors: true) // spending went down: green
```

**Rolling and counting numbers:**
```swift
KitoAnimatedNumberText(total) { KitoMoneyFormatting.string(Decimal($0), currency: .kes) }
KitoCountingText(12_480)   // counts up from 0 when it appears
```

**Durations, distances, file sizes:**
```swift
KitoDurationFormatting.short(3_900)            // "1h 5m"
KitoDurationFormatting.clock(245)              // "4:05"
KitoDistanceFormatting.string(meters: 1_240)   // "1.2 km"
KitoFileSizeFormatting.string(bytes: 1_200_000) // "1.2 MB"
```

**Relative dates:**
```swift
KitoDateFormatting.abbreviated(message.sentAt)  // "5m", "3h", "2d"
KitoDateFormatting.dayLabel(transaction.date)   // "Today", "Yesterday", "Monday"
KitoDateFormatting.timeRange(slot.start, slot.end) // "9:00 – 10:30 AM"
```

**Kenyan phone numbers:**
```swift
let phone = KitoKenyanPhoneNumber("0712 345 678")!
phone.e164            // "+254712345678"
phone.international   // "+254 712 345 678"
phone.masked          // "+254 7•• ••• 678"
phone.carrier         // .safaricom (best-effort from the prefix)
KitoPhoneFormatting.kenyanAsYouType("071234")   // "0712 34"
```

**In a checkout summary:**
```swift
VStack(alignment: .leading) {
    ForEach(cart.items) { item in
        Text(item.lineTotal.kitoFormatted(currency: .kes))
    }
    Text("Total: \(cart.subtotal.kitoFormatted(currency: .kes))")
        .font(.headline)
}
```

## Right-to-left

`KitoChangeBadge` lays out right to left automatically, and its trend arrows use the `forward`
symbol variants, so they point leftwards in Arabic or Hebrew along with mirrored charts.
`percent` and `signedPercent` take a `locale` (default `.current`), and the badge passes the
environment's `\.locale`. `KitoMoneyFormatting` and `grouped` stay fixed ("1,234.56") on purpose;
use `Decimal.kitoFormatted(currency:locale:)` for amounts in the user's own locale.

## License

MIT
