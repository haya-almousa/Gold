//
//  Zakatcalculator.swift
//  Gold
//
//  Created by Raghad Alamoudi on 09/11/1447 AH.
//

import SwiftUI

// MARK: - Zakat Calculator View
struct ZakatCalculatorView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var goldGrams: Double = 0
    @State private var goldGramsText: String = ""
    @FocusState private var isInputFocused: Bool

    // Nisab threshold in grams of 24K gold
    let nisabGrams: Double = 85.0
    // Zakat rate
    let zakatRate: Double = 0.025
    // Gold price per gram in SAR (approx. 24K gold price — update as needed)
    let goldPricePerGram: Double = 369.08

    // MARK: - Computed Properties
    var totalValueSAR: Double {
        goldGrams * goldPricePerGram
    }

    var zakatDueSAR: Double {
        totalValueSAR * zakatRate
    }

    var nisabMet: Bool {
        goldGrams >= nisabGrams
    }

    // MARK: - Colors
    var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "141210") : Color(hex: "F5EFE8")
    }

    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1E1A15") : Color(hex: "FFFFFF")
    }

    var nisabCardColor: Color {
        colorScheme == .dark
            ? (nisabMet ? Color(hex: "1A2E1A") : Color(hex: "2E1A1A"))
            : (nisabMet ? Color(hex: "FFF0E8") : Color(hex: "FFE8E8"))
    }

    var zakatCardColor: Color {
        colorScheme == .dark ? Color(hex: "2A2010") : Color(hex: "FFF8EE")
    }

    var goldAccent: Color {
        Color(hex: "C9A84C")
    }

    var goldAccentLight: Color {
        Color(hex: "E8C96A")
    }

    var primaryText: Color {
        colorScheme == .dark ? Color(hex: "F0E8D8") : Color(hex: "2C1F0E")
    }

    var secondaryText: Color {
        colorScheme == .dark ? Color(hex: "8A7A62") : Color(hex: "9A8A72")
    }

    var inputBackground: Color {
        colorScheme == .dark ? Color(hex: "2A2418") : Color(hex: "F0E8DC")
    }

    var nisabStatusColor: Color {
        nisabMet
            ? (colorScheme == .dark ? Color(hex: "5DB85D") : Color(hex: "C0522A"))
            : Color(hex: "D94F4F")
    }

    var dividerColor: Color {
        colorScheme == .dark ? Color(hex: "2E2820") : Color(hex: "E8DDD0")
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {

                        // MARK: Header
                        headerView

                        // MARK: Gold Input Card
                        goldInputCard

                        // MARK: Nisab Status Card
                        nisabStatusCard

                        // MARK: Zakat Due Card
                        zakatDueCard

                        // MARK: How It's Calculated Card
                        howItIsCalculatedCard

                        Spacer(minLength: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
            }
            .navigationBarHidden(true)
            .onTapGesture {
                isInputFocused = false
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Header
    var headerView: some View {
        HStack(alignment: .top) {
            Button(action: {}) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(hex: "2A2418") : Color(hex: "EDE3D8"))
                        .frame(width: 44, height: 44)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(goldAccent)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Zakat Calculator")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(primaryText)

                Text("Nisab threshold: 85g of gold")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(secondaryText)
            }
            .padding(.leading, 8)

            Spacer()
        }
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Gold Input Card
    var goldInputCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("YOUR TOTAL GOLD (GRAMS, 24K EQUIVALENT)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryText)
                .tracking(0.8)

            HStack {
                TextField("0", text: $goldGramsText)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(primaryText)
                    .focused($isInputFocused)
                    .onChange(of: goldGramsText) { newValue in
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        if filtered != newValue {
                            goldGramsText = filtered
                        }
                        goldGrams = Double(filtered) ?? 0
                    }

                Spacer()

                VStack(spacing: 0) {
                    Button(action: {
                        goldGrams += 1
                        goldGramsText = formatGrams(goldGrams)
                    }) {
                        Image(systemName: "chevron.up")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(secondaryText)
                            .frame(width: 28, height: 20)
                    }
                    Button(action: {
                        if goldGrams > 0 {
                            goldGrams -= 1
                            goldGramsText = formatGrams(goldGrams)
                        }
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(secondaryText)
                            .frame(width: 28, height: 20)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(inputBackground)
            .cornerRadius(12)
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Nisab Status Card
    var nisabStatusCard: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: nisabMet ? "checkmark" : "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(nisabStatusColor)
                Text(nisabMet ? "Nisab Threshold Met" : "Nisab Threshold Not Met")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(nisabStatusColor)
            }

            Text(nisabMet
                 ? "Your \(formatGrams(goldGrams))g exceeds the 85g Nisab"
                 : goldGrams == 0
                    ? "Enter your gold amount to check"
                    : "Your \(formatGrams(goldGrams))g is below the 85g Nisab")
                .font(.system(size: 14))
                .foregroundColor(secondaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .padding(.horizontal, 20)
        .background(nisabCardColor)
        .cornerRadius(18)
        .animation(.easeInOut(duration: 0.3), value: nisabMet)
    }

    // MARK: - Zakat Due Card
    var zakatDueCard: some View {
        VStack(spacing: 10) {
            Text("ZAKAT DUE (2.5%)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryText)
                .tracking(0.8)

            if nisabMet {
                Text("SAR \(formatCurrency(zakatDueSAR))")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundColor(goldAccent)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("of SAR \(formatCurrency(totalValueSAR)) total value")
                    .font(.system(size: 14))
                    .foregroundColor(secondaryText)
            } else {
                Text("SAR —")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundColor(secondaryText.opacity(0.5))

                Text(goldGrams == 0 ? "Enter gold amount above" : "Nisab threshold not met")
                    .font(.system(size: 14))
                    .foregroundColor(secondaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .background(zakatCardColor)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    LinearGradient(
                        colors: [goldAccent.opacity(0.4), goldAccent.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: goldAccent.opacity(colorScheme == .dark ? 0.15 : 0.08), radius: 16, x: 0, y: 6)
        .animation(.easeInOut(duration: 0.25), value: nisabMet)
    }

    // MARK: - How It's Calculated Card
    var howItIsCalculatedCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How it's calculated")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(goldAccent)
                .padding(.bottom, 16)

            calculationRow(
                label: "Nisab (gold)",
                value: "85 grams of 24K"
            )

            Divider()
                .background(dividerColor)
                .padding(.vertical, 14)

            calculationRow(
                label: "Zakat rate",
                value: "2.5% of total value"
            )

            Divider()
                .background(dividerColor)
                .padding(.vertical, 14)

            calculationRow(
                label: "Lunar year",
                value: "Gold held ≥ 1 Hijri year"
            )

            if nisabMet && goldGrams > 0 {
                Divider()
                    .background(dividerColor)
                    .padding(.vertical, 14)

                calculationRow(
                    label: "Gold price used",
                    value: "SAR \(formatCurrency(goldPricePerGram))/g"
                )
            }
        }
        .padding(20)
        .background(cardBackgroundColor)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 12, x: 0, y: 4)
    }

    func calculationRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 15))
                .foregroundColor(secondaryText)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(primaryText)
        }
    }

    // MARK: - Helpers
    func formatGrams(_ grams: Double) -> String {
        if grams == floor(grams) {
            return String(Int(grams))
        }
        return String(format: "%.1f", grams)
    }

    func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b = Double(rgbValue & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}

// MARK: - Preview
#Preview {
    ZakatCalculatorView()
}

#Preview("Dark Mode") {
    ZakatCalculatorView()
        .preferredColorScheme(.dark)
}
