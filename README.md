# KitoFormatting

Currency (KES, USD, and more), compact number, percent, and date formatting
— locale-aware, built on Foundation's native `FormatStyle` rather than
hand-rolled string math.

## Install

```swift
.package(url: "https://github.com/WykSofts-Inc/KitoFormatting.git", from: "1.0.0"),
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

## License

MIT
