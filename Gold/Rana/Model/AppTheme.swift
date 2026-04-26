//
//  AppTheme.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

internal import SwiftUI


struct AppTheme {
    let gold:         Color
    let goldLight:    Color
    let goldDark:     Color
    let goldGlow:     Color
    let bg:           Color
    let surface:      Color
    let surface2:     Color
    let surface3:     Color
    let border:       Color
    let borderStrong: Color
    let text:         Color
    let textMuted:    Color
    let textFaint:    Color
    let warn:         Color
    let warnBg:       Color

    static let dark = AppTheme(
        gold:         Color(hex: "#D4A843"),
        goldLight:    Color(hex: "#E8C06A"),
        goldDark:     Color(hex: "#A07820"),
        goldGlow:     Color(hex: "#D4A843").opacity(0.16),
        bg:           Color(hex: "#0C0B09"),
        surface:      Color(hex: "#141210"),
        surface2:     Color(hex: "#1C1A15"),
        surface3:     Color(hex: "#242018"),
        border:       Color(hex: "#D4A843").opacity(0.16),
        borderStrong: Color(hex: "#D4A843").opacity(0.38),
        text:         Color(hex: "#F2EDE0"),
        textMuted:    Color(hex: "#8C8272"),
        textFaint:    Color(hex: "#4A4235"),
        warn:         Color(hex: "#E07B42"),
        warnBg:       Color(hex: "#E07B42").opacity(0.14)
    )

    static let light = AppTheme(
        gold:         Color(hex: "#B8860B"),
        goldLight:    Color(hex: "#C9960E"),
        goldDark:     Color(hex: "#7A5A00"),
        goldGlow:     Color(hex: "#B8860B").opacity(0.10),
        bg:           Color(hex: "#FAF7F0"),
        surface:      Color(hex: "#FFFFFF"),
        surface2:     Color(hex: "#F5F0E6"),
        surface3:     Color(hex: "#EDE7D8"),
        border:       Color(hex: "#B8860B").opacity(0.18),
        borderStrong: Color(hex: "#B8860B").opacity(0.38),
        text:         Color(hex: "#1C1810"),
        textMuted:    Color(hex: "#7A6E58"),
        textFaint:    Color(hex: "#B8AA90"),
        warn:         Color(hex: "#C05820"),
        warnBg:       Color(hex: "#C05820").opacity(0.10)
    )

    var goldGradient: LinearGradient {
        LinearGradient(
            colors: [goldDark, goldLight, gold, goldLight, goldDark],
            startPoint: .leading, endPoint: .trailing
        )
    }

    var buttonGradient: LinearGradient {
        LinearGradient(
            colors: [goldDark, gold, goldLight],
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
