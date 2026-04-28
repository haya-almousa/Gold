//
//  AppTheme.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

internal import SwiftUI


struct AppTheme {
    // Primary accent (was "gold" — now Navy-driven primary)
    let gold:         Color   // primary accent — Navy
    let goldLight:    Color   // lighter primary — Emerald
    let goldDark:     Color   // deep primary — Deep Navy
    let goldGlow:     Color   // glow / tint overlay

    // Backgrounds & surfaces
    let bg:           Color
    let surface:      Color
    let surface2:     Color
    let surface3:     Color

    // Borders
    let border:       Color
    let borderStrong: Color

    // Typography
    let text:         Color
    let textMuted:    Color
    let textFaint:    Color

    // Semantic: "warn" repurposed as Emerald highlight / best-value accent
    let warn:         Color
    let warnBg:       Color

    // ── DARK MODE ──────────────────────────────────────────────────────────────
    // Palette:
    //   Navy primary   #1A2B4D  → goldDark (deep)  #0F1A30
    //   Emerald accent #009E60  → goldLight
    //   Beige highlight #D2C1A1 → gold (used for prices, key values)
    // Backgrounds stay very dark navy-tinted for luxury depth
    static let dark = AppTheme(
        gold:         Color(hex: "#D2C1A1"),   // Beige — price values, key highlights
        goldLight:    Color(hex: "#009E60"),   // Emerald — secondary accent, edit icons
        goldDark:     Color(hex: "#1A2B4D"),   // Navy — primary buttons, badges
        goldGlow:     Color(hex: "#1A2B4D").opacity(0.20),
        bg:           Color(hex: "#070C14"),   // Near-black with navy cast
        surface:      Color(hex: "#0E1623"),   // Dark navy surface
        surface2:     Color(hex: "#141F30"),   // Slightly lighter navy
        surface3:     Color(hex: "#1A2640"),   // Card inner surfaces
        border:       Color(hex: "#1A2B4D").opacity(0.50),
        borderStrong: Color(hex: "#009E60").opacity(0.40),
        text:         Color(hex: "#EDE5D5"),   // Warm off-white (beige-tinted)
        textMuted:    Color(hex: "#7E8FA8"),   // Muted navy-grey
        textFaint:    Color(hex: "#3A4A60"),   // Very faint navy
        warn:         Color(hex: "#009E60"),   // Emerald for best-value banners
        warnBg:       Color(hex: "#009E60").opacity(0.12)
    )

    // ── LIGHT MODE ─────────────────────────────────────────────────────────────
    // Lighter versions of the same palette — backgrounds are beige-tinted white,
    // primary stays readable navy, emerald stays vivid but slightly softened.
    static let light = AppTheme(
        gold:         Color(hex: "#8B6F4E"),   // Warm beige-brown for prices
        goldLight:    Color(hex: "#007A4A"),   // Deeper emerald (legible on light bg)
        goldDark:     Color(hex: "#1E3560"),   // Navy buttons & primary elements
        goldGlow:     Color(hex: "#1A2B4D").opacity(0.08),
        bg:           Color(hex: "#F5F0E8"),   // Warm beige background
        surface:      Color(hex: "#FFFFFF"),
        surface2:     Color(hex: "#EDE7DA"),   // Beige-tinted card surface
        surface3:     Color(hex: "#E4DDD0"),   // Slightly deeper beige
        border:       Color(hex: "#1A2B4D").opacity(0.14),
        borderStrong: Color(hex: "#007A4A").opacity(0.30),
        text:         Color(hex: "#111C2E"),   // Deep navy text
        textMuted:    Color(hex: "#5A6E85"),   // Muted blue-grey
        textFaint:    Color(hex: "#A8B4C0"),   // Very faint
        warn:         Color(hex: "#007A4A"),   // Emerald for best-value banners
        warnBg:       Color(hex: "#007A4A").opacity(0.08)
    )

    var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldDark, Color(hex: "#2A3F6B"), goldDark],
            startPoint: .leading, endPoint: .trailing
        )
    }

    var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [goldDark, Color(hex: "#243558"), Color(hex: "#1A2B4D")],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

private struct ThemeKey: EnvironmentKey {
    static let defaultValue = AppTheme.light
}

extension EnvironmentValues {
    var theme: AppTheme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: h).scanHexInt64(&rgb)
        self.init(
            red:   Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >>  8) & 0xFF) / 255,
            blue:  Double( rgb        & 0xFF) / 255
        )
    }
}
