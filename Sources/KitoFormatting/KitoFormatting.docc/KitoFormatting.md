# ``KitoFormatting``

Locale-aware currency, number, date, duration and phone number formatting.

## Overview

KitoFormatting turns values into display strings for amounts, compact numbers,
percentages, dates, durations, distances, file sizes and Kenyan phone numbers.
It is built on Foundation's native `FormatStyle` rather than hand-rolled string
math.

Currency formatting comes in two flavours. `kitoFormatted(currency:)` on
`Decimal` follows the device locale, while ``KitoMoneyFormatting`` and
`kitoAmount(in:)` produce amounts that read the same on every device — useful
for receipts, M-Pesa prompts and anything shared between users.

```swift
let price = Decimal(1250.50)

Text(price.kitoFormatted(currency: .kes))          // "KSh 1,250.50"
Text(price.kitoAmount(in: .kes))                   // "KES 1,250.50"
Text(KitoNumberFormatting.compact(47_200))         // "47.2K"
Text(KitoDateFormatting.relative(order.placedAt))  // "2 minutes ago"
```

A few small SwiftUI views sit on top of the formatters: ``KitoChangeBadge`` shows
a signed change with an arrow and colour, ``KitoAnimatedNumberText`` rolls between
values, and ``KitoCountingText`` counts up when it appears.

## Topics

### Money

- ``KitoCurrency``
- ``KitoMoneyFormatting``
- ``KitoCurrencyDisplay``
- ``KitoCents``

### Numbers

- ``KitoNumberFormatting``
- ``KitoTrend``

### Dates and Durations

- ``KitoDateFormatting``
- ``KitoDurationFormatting``

### Measurements

- ``KitoDistanceFormatting``
- ``KitoDistanceSystem``
- ``KitoFileSizeFormatting``

### Phone Numbers

- ``KitoKenyanPhoneNumber``
- ``KitoKenyanCarrier``
- ``KitoPhoneFormatting``

### Views

- ``KitoChangeBadge``
- ``KitoChangeBadgeStyle``
- ``KitoAnimatedNumberText``
- ``KitoCountingText``
