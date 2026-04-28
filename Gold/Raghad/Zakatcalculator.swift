//
//  Zakatcalculator.swift
//  Gold
//
//  Created by Raghad Alamoudi on 09/11/1447 AH.
//


internal import SwiftUI

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
        colorScheme == .dark ? Color("141210") : Color("F5EFE8")
    }

    var cardBackgroundColor: Color {
        colorScheme == .dark ? Color("1E1A15") : Color("FFFFFF")
    }

    var nisabCardColor: Color {
        colorScheme == .dark
        ? (nisabMet ? Color("1A2E1A") : Color("2E1A1A"))
        : (nisabMet ? Color("FFF0E8") : Color("FFE8E8"))
    }

    var zakatCardColor: Color {
        colorScheme == .dark ? Color("2A2010") : Color("FFF8EE")
    }

    var goldAccent: Color {
        Color("C9A84C")
    }

    var goldAccentLight: Color {
        Color("E8C96A")
    }

    var primaryText: Color {
        colorScheme == .dark ? Color("F0E8D8") : Color("2C1F0E")
    }

    var secondaryText: Color {
        colorScheme == .dark ? Color("8A7A62") : Color("9A8A72")
    }

    var inputBackground: Color {
        colorScheme == .dark ? Color("2A2418") : Color("F0E8DC")
    }

    var nisabStatusColor: Color {
        nisabMet
        ? (colorScheme == .dark ? Color("5DB85D") : Color("C0522A"))
        : Color("D94F4F")
    }

    var dividerColor: Color {
        colorScheme == .dark ? Color("2E2820") : Color("E8DDD0")
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
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("حاسبة الزكاة")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(primaryText)

                Text("حد النصاب: 85 جرام ذهب")
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
            Text("إجمالي الذهب لديك (جرام، ما يعادل 24 قيراط)")
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
                Text(nisabMet ? "تم بلوغ النصاب" : "لم يتم بلوغ النصاب")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(nisabStatusColor)
            }

            Text(nisabMet
                 ? "كمية \(formatGrams(goldGrams)) جم تتجاوز نصاب 85 جم"
                 : goldGrams == 0
                    ? "أدخل كمية الذهب للتحقق"
                    : "كمية \(formatGrams(goldGrams)) جم أقل من نصاب 85 جم")
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
            Text("الزكاة المستحقة (2.5%)")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryText)
                .tracking(0.8)

            if nisabMet {
                Text("ريال \(formatCurrency(zakatDueSAR))")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundColor(goldAccent)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)

                Text("من إجمالي قيمة \(formatCurrency(totalValueSAR)) ريال")
                    .font(.system(size: 14))
                    .foregroundColor(secondaryText)
            } else {
                Text("ريال —")
                    .font(.system(size: 44, weight: .bold, design: .serif))
                    .foregroundColor(secondaryText.opacity(0.5))

                Text(goldGrams == 0 ? "أدخل كمية الذهب بالأعلى" : "لم يتم بلوغ النصاب")
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
            Text("طريقة الحساب")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundColor(goldAccent)
                .padding(.bottom, 16)

            calculationRow(
                label: "النصاب (الذهب)",
                value: "85 جرام من 24 قيراط"
            )

            Divider()
                .background(dividerColor)
                .padding(.vertical, 14)

            calculationRow(
                label: "نسبة الزكاة",
                value: "2.5% من إجمالي القيمة"
            )

            Divider()
                .background(dividerColor)
                .padding(.vertical, 14)

            calculationRow(
                label: "الحول",
                value: "مرور سنة هجرية على الذهب"
            )

            if nisabMet && goldGrams > 0 {
                Divider()
                    .background(dividerColor)
                    .padding(.vertical, 14)

                calculationRow(
                    label: "سعر الذهب المستخدم",
                    value: "ريال \(formatCurrency(goldPricePerGram))/جم"
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

// MARK: - Preview
#Preview {
    ZakatCalculatorView()
}

#Preview("Dark Mode") {
    ZakatCalculatorView()
        .preferredColorScheme(.dark)
}
