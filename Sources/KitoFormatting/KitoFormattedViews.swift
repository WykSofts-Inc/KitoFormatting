//
//  KitoFormattedViews.swift
//  KitoFormatting
//
//  Created by Wycliff on 9/24/26.
//  Copyright © 2026 wyksoftsinc.com. All rights reserved.
//

import SwiftUI
import KitoCore

/// A number whose digits roll to their new value (`.numericText`) whenever it changes — a
/// balance, a cart total, a live counter. Reduce Motion swaps the roll for a plain update.
///
/// ```swift
/// KitoAnimatedNumberText(balance) { KitoMoneyFormatting.string(Decimal($0), currency: .kes) }
///     .font(.largeTitle.bold())
/// ```
public struct KitoAnimatedNumberText: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let value: Double
    let format: (Double) -> String

    public init(_ value: Double, format: @escaping (Double) -> String = { KitoNumberFormatting.grouped($0) }) {
        self.value = value
        self.format = format
    }

    public var body: some View {
        Text(format(value))
            .monospacedDigit()
            .contentTransition(reduceMotion ? .identity : .numericText(value: value))
            .animation(reduceMotion ? nil : .snappy(duration: 0.35), value: value)
    }
}

/// Counts up (or down) through every value between the old number and the new one, like a
/// scoreboard — `startsFromZero` counts in from 0 when it first appears. Reduce Motion jumps
/// straight to the value.
public struct KitoCountingText: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let value: Double
    let duration: Double
    let startsFromZero: Bool
    let format: (Double) -> String

    @State private var shown: Double?

    public init(
        _ value: Double,
        duration: Double = 1.1,
        startsFromZero: Bool = true,
        format: @escaping (Double) -> String = { KitoNumberFormatting.grouped($0) }
    ) {
        self.value = value
        self.duration = duration
        self.startsFromZero = startsFromZero
        self.format = format
    }

    public var body: some View {
        KitoCountingTextCore(value: shown ?? (startsFromZero ? 0 : value), format: format)
            .onAppear { animate(to: value) }
            .onChange(of: value) { _, newValue in animate(to: newValue) }
            .accessibilityLabel(format(value))
    }

    private func animate(to target: Double) {
        if shown == nil { shown = startsFromZero ? 0 : target }
        if reduceMotion {
            shown = target
        } else {
            withAnimation(.easeOut(duration: duration)) { shown = target }
        }
    }
}

/// The animatable part: SwiftUI interpolates `value` frame by frame and the text re-renders.
private struct KitoCountingTextCore: View, Animatable {
    var value: Double
    let format: (Double) -> String

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(format(value)).monospacedDigit()
    }
}

/// How `KitoChangeBadge` is drawn.
public enum KitoChangeBadgeStyle: Sendable, CaseIterable {
    /// A tinted capsule with an arrow — stat tiles and portfolio rows.
    case pill
    /// Coloured text and arrow, no background — inline in a sentence or table.
    case plain
    /// A solid capsule with white text — the loudest, for a hero number.
    case solid
}

/// "+12.4%" in green with an up arrow, "−3.1%" in red with a down arrow, grey when flat —
/// coloured from the theme's `success`/`danger`.
public struct KitoChangeBadge: View {
    @Environment(\.kitoTheme) private var theme
    @Environment(\.locale) private var locale
    let fraction: Double
    let fractionDigits: Int
    let style: KitoChangeBadgeStyle
    let invertsColors: Bool

    /// - Parameter invertsColors: For numbers where down is good (spending, delivery time).
    public init(_ fraction: Double, fractionDigits: Int = 1, style: KitoChangeBadgeStyle = .pill, invertsColors: Bool = false) {
        self.fraction = fraction
        self.fractionDigits = fractionDigits
        self.style = style
        self.invertsColors = invertsColors
    }

    private var trend: KitoTrend { KitoTrend(fraction) }

    private var tint: Color {
        switch trend {
        case .flat: return theme.colors.onBackground.opacity(0.55)
        case .up: return invertsColors ? theme.colors.danger : theme.colors.success
        case .down: return invertsColors ? theme.colors.success : theme.colors.danger
        }
    }

    public var body: some View {
        let label = HStack(spacing: 3) {
            Image(systemName: trend.systemImage).font(.caption2.weight(.heavy))
            Text(KitoNumberFormatting.signedPercent(fraction, fractionDigits: fractionDigits, locale: locale))
                .font(.caption.weight(.bold))
                .monospacedDigit()
        }

        Group {
            switch style {
            case .plain:
                label.foregroundStyle(tint)
            case .pill:
                label
                    .foregroundStyle(tint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tint.opacity(0.14), in: Capsule())
            case .solid:
                label
                    .foregroundStyle(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(tint, in: Capsule())
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(trend.accessibilityLabel) \(KitoNumberFormatting.signedPercent(fraction, fractionDigits: fractionDigits, locale: locale))")
    }
}
