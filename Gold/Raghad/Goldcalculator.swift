//
//  Goldcalculator.swift
//  Gold
//
//  Created by Raghad Alamoudi on 09/11/1447 AH.
//

import SwiftUI

// MARK: - Price State
enum PriceState {
    case loading
    case loaded(GoldQuote)
    case failed(String)
}

// MARK: - Gold Calculator View
struct GoldCalculatorView: View {
    @Environment(\.colorScheme) var colorScheme

    // MARK: - API
    let apiService: any GoldPriceProviding
    @State private var priceState: PriceState = .loading
    @State private var lastRefreshed: Date? = nil

    // MARK: - State
    @State private var weightText: String = ""
    @State private var weight: Double = 0
    @State private var selectedKarat: KaratOption = .k24
    @State private var manufacturingFeeText: String = ""
    @State private var manufacturingFee: Double = 0
    @FocusState private var focusedField: Field?

    enum Field { case weight, fee }

    // MARK: - Init
    init(apiService: any GoldPriceProviding = GoldAPIService()) {
        self.apiService = apiService
    }

    // MARK: - Karat Options
    enum KaratOption: String, CaseIterable, Identifiable {
        case k24 = "24 Karat (999)"
        case k22 = "22 Karat (916)"
        case k21 = "21 Karat (875)"
        case k18 = "18 Karat (750)"
        case k14 = "14 Karat (585)"
        case k10 = "10 Karat (417)"

        var id: String { rawValue }

        var purity: Double {
            switch self {
            case .k24: return 1.0
            case .k22: return 0.916
            case .k21: return 0.875
            case .k18: return 0.750
            case .k14: return 0.585
            case .k10: return 0.417
            }
        }
    }

    // MARK: - Live Price Helpers
    var currentQuote: GoldQuote? {
        if case .loaded(let q) = priceState { return q }
        return nil
    }

    var goldPrice24KSAR: Double {
        currentQuote?.price24KPerGramSAR ?? 369.07
    }

    var usdPerGram: Double {
        currentQuote?.usdPerGram ?? 98.42
    }

    // MARK: - Computed
    var goldValueSAR: Double {
        weight * selectedKarat.purity * goldPrice24KSAR
    }

    var manufacturingAmountSAR: Double {
        goldValueSAR * (manufacturingFee / 100)
    }

    var totalValueSAR: Double {
        goldValueSAR + manufacturingAmountSAR
    }

    var totalValueUSD: Double {
        totalValueSAR / 3.75
    }

    var rateUsedUSD: Double {
        usdPerGram * selectedKarat.purity
    }

    // MARK: - Colors
    var bg: Color { colorScheme == .dark ? Color(hex: "141210") : Color(hex: "F5EFE8") }
    var cardBg: Color { colorScheme == .dark ? Color(hex: "1E1A15") : Color(hex: "FFFFFF") }
    var inputBg: Color { colorScheme == .dark ? Color(hex: "2A2418") : Color(hex: "F0E8DC") }
    var estimatedCardBg: Color { colorScheme == .dark ? Color(hex: "2A2010") : Color(hex: "FFF0DC") }
    var gold: Color { Color(hex: "C9A84C") }
    var primaryText: Color { colorScheme == .dark ? Color(hex: "F0E8D8") : Color(hex: "2C1F0E") }
    var secondaryText: Color { colorScheme == .dark ? Color(hex: "8A7A62") : Color(hex: "9A8A72") }
    var dividerColor: Color { colorScheme == .dark ? Color(hex: "2E2820") : Color(hex: "E8DDD0") }
    var errorColor: Color { Color(hex: "D94F4F") }

    // MARK: - Body
    var body: some View {
        ZStack {
            bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    headerView
                    if case .failed(let msg) = priceState {
                        errorBanner(msg)
                    }
                    inputsCard
                    estimatedValueCard
                    breakdownCard
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
            }
            .refreshable {
                await fetchPrice()
            }
        }
        .onTapGesture { focusedField = nil }
        .task { await fetchPrice() }
    }

    // MARK: - Fetch Price
    func fetchPrice() async {
        priceState = .loading
        do {
            let quote = try await apiService.fetchGoldQuote()
            priceState = .loaded(quote)
            lastRefreshed = Date()
        } catch {
            priceState = .failed("تعذّر تحديث السعر. اسحب للأسفل للمحاولة مجدداً.")
        }
    }

    // MARK: - Header
    var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Gold Calculator")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundColor(primaryText)

            HStack(spacing: 6) {
                switch priceState {
                case .loading:
                    ProgressView().scaleEffect(0.65).frame(width: 10, height: 10)
                case .loaded:
                    Circle().fill(Color(hex: "4CAF50")).frame(width: 7, height: 7)
                case .failed:
                    Circle().fill(errorColor).frame(width: 7, height: 7)
                }

                switch priceState {
                case .loading:
                    Text("جارٍ تحميل السعر المباشر...")
                        .font(.system(size: 14))
                        .foregroundColor(secondaryText)
                case .loaded(let quote):
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Live price · 24K = SAR \(String(format: "%.2f", quote.price24KPerGramSAR))/g")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryText)
                        if quote.changePercent != 0 {
                            Text("\(quote.changePercent >= 0 ? "▲" : "▼") \(String(format: "%.2f", abs(quote.changePercent)))%")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(quote.changePercent >= 0 ? Color(hex: "4CAF50") : errorColor)
                        }
                    }
                case .failed:
                    Text("Live price · 24K = SAR \(String(format: "%.2f", goldPrice24KSAR))/g (آخر سعر)")
                        .font(.system(size: 14))
                        .foregroundColor(secondaryText)
                }

                Spacer()

                Button {
                    Task { await fetchPrice() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(gold)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
        .padding(.bottom, 4)
    }

    // MARK: - Error Banner
    func errorBanner(_ message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(errorColor)
                .font(.system(size: 13))
            Text(message)
                .font(.system(size: 13))
                .foregroundColor(errorColor)
            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(errorColor.opacity(0.1))
        .cornerRadius(12)
    }

    // MARK: - Inputs Card
    var inputsCard: some View {
        VStack(alignment: .leading, spacing: 14) {

            // Weight
            VStack(alignment: .leading, spacing: 8) {
                Text("WEIGHT (GRAMS)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .tracking(0.8)

                HStack {
                    ZStack(alignment: .leading) {
                        if weightText.isEmpty {
                            Text("10")
                                .font(.system(size: 18))
                                .foregroundColor(secondaryText.opacity(0.45))
                                .allowsHitTesting(false)
                        }
                        TextField("", text: $weightText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 18))
                            .foregroundColor(primaryText)
                            .tint(gold)
                    }
                        .focused($focusedField, equals: .weight)
                        .onChange(of: weightText) { v in
                            let f = v.filter { $0.isNumber || $0 == "." }
                            if f != v { weightText = f }
                            weight = Double(f) ?? 0
                        }
                    Spacer()
                    stepperButtons(
                        increment: { weight = max(0, weight + 1); weightText = fmt(weight) },
                        decrement: { weight = max(0, weight - 1); weightText = fmt(weight) }
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(inputBg)
                .cornerRadius(12)
            }

            // Karat Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("KARAT")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .tracking(0.8)

                Menu {
                    ForEach(KaratOption.allCases) { option in
                        Button(option.rawValue) { selectedKarat = option }
                    }
                } label: {
                    HStack {
                        Text(selectedKarat.rawValue)
                            .font(.system(size: 16))
                            .foregroundColor(primaryText)
                        Spacer()
                        Image(systemName: "chevron.up.chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(secondaryText)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
                    .background(inputBg)
                    .cornerRadius(12)
                }
            }

            // Manufacturing Fee
            VStack(alignment: .leading, spacing: 8) {
                Text("MANUFACTURING FEE (%)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .tracking(0.8)

                HStack {
                    ZStack(alignment: .leading) {
                        if manufacturingFeeText.isEmpty {
                            Text("5")
                                .font(.system(size: 18))
                                .foregroundColor(secondaryText.opacity(0.45))
                                .allowsHitTesting(false)
                        }
                        TextField("", text: $manufacturingFeeText)
                            .keyboardType(.decimalPad)
                            .font(.system(size: 18))
                            .foregroundColor(primaryText)
                            .tint(gold)
                    }
                        .focused($focusedField, equals: .fee)
                        .onChange(of: manufacturingFeeText) { v in
                            let f = v.filter { $0.isNumber || $0 == "." }
                            if f != v { manufacturingFeeText = f }
                            manufacturingFee = Double(f) ?? 0
                        }
                    Spacer()
                    stepperButtons(
                        increment: { manufacturingFee = min(100, manufacturingFee + 1); manufacturingFeeText = fmt(manufacturingFee) },
                        decrement: { manufacturingFee = max(0, manufacturingFee - 1); manufacturingFeeText = fmt(manufacturingFee) }
                    )
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(inputBg)
                .cornerRadius(12)
            }
        }
        .padding(18)
        .background(cardBg)
        .cornerRadius(18)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Estimated Value Card
    var estimatedValueCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ESTIMATED VALUE")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(secondaryText)
                .tracking(0.8)

            if case .loading = priceState {
                HStack(spacing: 10) {
                    ProgressView()
                    Text("جارٍ تحميل السعر...")
                        .font(.system(size: 18))
                        .foregroundColor(secondaryText)
                }
                .frame(height: 52)
            } else {
                Text("SAR \(fmtCurrency(totalValueSAR))")
                    .font(.system(size: 42, weight: .bold, design: .serif))
                    .foregroundColor(gold)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("≈ $\(fmtCurrency(totalValueUSD)) USD")
                    .font(.system(size: 14))
                    .foregroundColor(secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(estimatedCardBg)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(
                    LinearGradient(colors: [gold.opacity(0.35), gold.opacity(0.08)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1
                )
        )
        .shadow(color: gold.opacity(0.12), radius: 14, x: 0, y: 6)
        .animation(.easeInOut(duration: 0.3), value: totalValueSAR)
    }

    // MARK: - Breakdown Card
    var breakdownCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Breakdown")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundColor(gold)
                Spacer()
                if let refreshed = lastRefreshed {
                    Text("آخر تحديث: \(timeAgo(refreshed))")
                        .font(.system(size: 11))
                        .foregroundColor(secondaryText)
                }
            }
            .padding(.bottom, 16)

            breakdownRow("Gold value", value: "SAR \(fmtCurrency(goldValueSAR))")
            Divider().background(dividerColor).padding(.vertical, 14)
            breakdownRow(
                "Manufacturing (\(manufacturingFee == floor(manufacturingFee) ? String(Int(manufacturingFee)) : String(format: "%.1f", manufacturingFee))%)",
                value: "SAR \(fmtCurrency(manufacturingAmountSAR))"
            )
            Divider().background(dividerColor).padding(.vertical, 14)
            breakdownRow("Rate used", value: "$\(String(format: "%.2f", rateUsedUSD))/g")

            if let quote = currentQuote, quote.changePercent != 0 {
                Divider().background(dividerColor).padding(.vertical, 14)
                breakdownRow(
                    "24hr change",
                    value: "\(quote.changePercent >= 0 ? "+" : "")\(String(format: "%.2f", quote.changePercent))%"
                )
            }
        }
        .padding(20)
        .background(cardBg)
        .cornerRadius(18)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.3 : 0.06), radius: 12, x: 0, y: 4)
    }

    // MARK: - Helpers
    func breakdownRow(_ label: String, value: String) -> some View {
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

    func stepperButtons(increment: @escaping () -> Void, decrement: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Button(action: increment) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .frame(width: 28, height: 18)
            }
            Button(action: decrement) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(secondaryText)
                    .frame(width: 28, height: 18)
            }
        }
    }

    func fmt(_ v: Double) -> String {
        v == floor(v) ? String(Int(v)) : String(format: "%.1f", v)
    }

    func fmtCurrency(_ v: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f.string(from: NSNumber(value: v)) ?? String(format: "%.2f", v)
    }

    func timeAgo(_ date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 { return "الآن" }
        if seconds < 3600 { return "منذ \(seconds / 60) دقيقة" }
        return "منذ \(seconds / 3600) ساعة"
    }
}

// MARK: - Preview
#Preview("Light") {
    GoldCalculatorView(apiService: MockGoldAPIService())
}

#Preview("Dark") {
    GoldCalculatorView(apiService: MockGoldAPIService())
        .preferredColorScheme(.dark)
}

// MARK: - Placeholder Color Helper
// Call this once in your App's init() to make all placeholders subtle:
// UITextField.appearance().attributedPlaceholder = NSAttributedString(
//     string: " ",
//     attributes: [.foregroundColor: UIColor.systemGray.withAlphaComponent(0.45)]
// )
