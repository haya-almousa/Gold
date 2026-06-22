//
//  Goldcalculator.swift
//  Gold
//
//  Created by Raghadi on 2/12/1447 AH.
//


internal import SwiftUI

// MARK: - Price State
enum PriceState {
    case loading
    case loaded(GoldQuote)
    case failed(String)
}

// MARK: - Gold Calculator View
struct GoldCalculatorView: View {
    // MARK: - API
    let apiService: any GoldPriceProviding
    let onBack: (() -> Void)?
    @State private var priceState: PriceState = .loading
    @State private var lastRefreshed: Date? = nil
    @State private var lastKnownPrice: Double? = nil

    // MARK: - State
    @State private var weightText: String = ""
    @State private var weight: Double = 0
    @State private var selectedKarat: KaratOption = .k18
    @State private var totalPriceText: String = ""
    @State private var totalPrice: Double = 0
    @FocusState private var focusedField: Field?
    @Environment(\.dismiss) private var dismiss

    enum Field { case weight, totalPrice }

    // MARK: - Init
    init(apiService: any GoldPriceProviding = GoldAPIService(),
         initialKarat: KaratOption? = nil,
         initialWeight: Double? = nil,
         onBack: (() -> Void)? = nil) {
        self.apiService = apiService
        self.onBack = onBack
        if let k = initialKarat { _selectedKarat = State(initialValue: k) }
        if let w = initialWeight, w > 0 {
            _weight = State(initialValue: w)
            _weightText = State(initialValue: w.truncatingRemainder(dividingBy: 1) == 0
                ? String(format: "%.0f", w)
                : String(format: "%.2g", w))
        }
    }

    // MARK: - Karat Options
    enum KaratOption: String, CaseIterable, Identifiable {
        case k24 = "24 قيراط"
        case k21 = "21 قيراط"
        case k18 = "18 قيراط"

        var id: String { rawValue }

        /// Exact purity = karat ÷ 24
        var purity: Double {
            switch self {
            case .k24: return 24.0 / 24.0
            case .k21: return 21.0 / 24.0
            case .k18: return 18.0 / 24.0
            }
        }
    }

    // MARK: - Live Price Helpers
    var currentQuote: GoldQuote? {
        if case .loaded(let q) = priceState { return q }
        return nil
    }

    var goldPrice24KSAR: Double? {
        currentQuote?.price24KPerGramSAR ?? lastKnownPrice
    }

    var usdPerGram: Double? {
        currentQuote?.usdPerGram
    }

    // MARK: - Computed (Reverse Breakdown)
    private let vatRate: Double = 0.15

    /// سعر الذهب الخالص = وزن × نقاء العيار × سعر جرام 24k
    var goldValueSAR: Double {
        guard let price = goldPrice24KSAR, weight > 0 else { return 0 }
        return weight * selectedKarat.purity * price
    }

    /// السعر بدون ضريبة = الإجمالي ÷ 1.15
    var priceWithoutVAT: Double {
        guard totalPrice > 0 else { return 0 }
        return totalPrice / (1 + vatRate)
    }

    /// المصنعية والربح = السعر بدون ضريبة - سعر الذهب الخالص
    var profitAndFeeSAR: Double {
        guard totalPrice > 0, goldPrice24KSAR != nil else { return 0 }
        return priceWithoutVAT - goldValueSAR
    }

    /// الضريبة = الإجمالي - السعر بدون ضريبة
    var vatAmountSAR: Double {
        guard totalPrice > 0 else { return 0 }
        return totalPrice - priceWithoutVAT
    }

    // MARK: - Colors
    private var backgroundColor: Color { Color(red: 0.96, green: 0.95, blue: 0.92) }
    private var primaryTeal: Color { Color(red: 0.02, green: 0.43, blue: 0.47) }
    private var secondaryTeal: Color { Color(red: 0.15, green: 0.53, blue: 0.56) }
    private var softTeal: Color { Color(red: 0.75, green: 0.84, blue: 0.85) }
    private var mutedGold: Color { Color(red: 0.66, green: 0.52, blue: 0.16) }

    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    topBar
                    karatSection
                    weightSection
                    totalPriceSection
                    if totalPrice > 0 && weight > 0 && goldPrice24KSAR != nil {
                        breakdownSection
                    }
                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 0)
                .padding(.bottom, 16)
                .safeAreaInset(edge: .top) { Color.clear.frame(height: 8) }
            }
            .refreshable {
                await fetchPrice()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture { focusedField = nil }
        .task { await fetchPrice() }
    }

    // MARK: - Fetch Price
    func fetchPrice() async {
        if lastKnownPrice == nil {
            priceState = .loading
        }
        do {
            let quote = try await apiService.fetchGoldQuote()
            lastKnownPrice = quote.price24KPerGramSAR
            priceState = .loaded(quote)
            lastRefreshed = Date()
        } catch {
            priceState = .failed("تعذّر تحديث السعر. اسحب للأسفل للمحاولة مجدداً.")
        }
    }

    // MARK: - Layout Sections
    private var topBar: some View {
        HStack {
            Text("حاسبة الذهب")
                .font(.appTitle2(.bold))
                .foregroundColor(.black)
                .minimumScaleFactor(0.6)
                .offset(x: 115)

            Spacer()

            NavigationLink(value: "back") { EmptyView() }

            Button(action: {
                if let back = onBack {
                    back()
                } else {
                    dismiss()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(primaryTeal)
                        .frame(width: 42, height: 42)
                    Image(systemName: "chevron.right")
                        .font(.appTitle3(.bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 20)
    }

    private var karatSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("العيار")
                .font(.appTitle3(.semibold))
                .foregroundColor(primaryTeal)

            HStack(spacing: 7) {
                karatChip(.k24, title: "24k")
                karatChip(.k21, title: "21k")
                karatChip(.k18, title: "18k")
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var weightSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("الوزن (جرام)*")
                .font(.appTitle3(.semibold))
                .foregroundColor(primaryTeal)

            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(softTeal)
                    .frame(height: 40)

                if weightText.isEmpty {
                    Text("مثال:5.5")
                        .font(.appBody(.semibold))
                        .foregroundColor(secondaryTeal.opacity(0.75))
                        .padding(.horizontal, 18)
                        .allowsHitTesting(false)
                }

                TextField("", text: $weightText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.appTitle3(.semibold))
                    .foregroundColor(primaryTeal)
                    .padding(.horizontal, 18)
                    .focused($focusedField, equals: .weight)
                    .onChange(of: weightText) {
                        let filtered = weightText.filter { $0.isNumber || $0 == "." }
                        if filtered != weightText { weightText = filtered }
                        weight = Double(filtered) ?? 0
                    }
            }
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.maincolor), lineWidth: 0.2))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var totalPriceSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("السعر الإجمالي (ريال)*")
                .font(.appTitle3(.semibold))
                .foregroundColor(primaryTeal)

            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(softTeal)
                    .frame(height: 40)

                if totalPriceText.isEmpty {
                    Text("مثال:1500")
                        .font(.appBody(.semibold))
                        .foregroundColor(secondaryTeal.opacity(0.75))
                        .padding(.horizontal, 18)
                        .allowsHitTesting(false)
                }

                TextField("", text: $totalPriceText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.appTitle3(.semibold))
                    .foregroundColor(primaryTeal)
                    .padding(.horizontal, 18)
                    .focused($focusedField, equals: .totalPrice)
                    .onChange(of: totalPriceText) {
                        let filtered = totalPriceText.filter { $0.isNumber || $0 == "." }
                        if filtered != totalPriceText { totalPriceText = filtered }
                        totalPrice = Double(filtered) ?? 0
                    }
            }
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.maincolor), lineWidth: 0.2))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var breakdownSection: some View {
        VStack(spacing: 0) {
            Text("تفصيل السعر")
                .font(.appTitle2(.bold))
                .foregroundColor(mutedGold)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.bottom, 16)

            VStack(spacing: 12) {
                breakdownRow(
                    label: "سعر الذهب الخالص",
                    value: "SAR \(fmtCurrency(goldValueSAR))",
                    color: primaryTeal
                )

                Divider().background(softTeal)

                breakdownRow(
                    label: "المصنعية والربح",
                    value: profitAndFeeSAR >= 0
                        ? "SAR \(fmtCurrency(profitAndFeeSAR))"
                        : "— (راجع الوزن أو العيار)",
                    color: profitAndFeeSAR >= 0 ? secondaryTeal : .red
                )

                Divider().background(softTeal)

                breakdownRow(
                    label: "ضريبة القيمة المضافة (15%)",
                    value: "SAR \(fmtCurrency(vatAmountSAR))",
                    color: secondaryTeal
                )

                Divider().background(softTeal)

                breakdownRow(
                    label: "الإجمالي",
                    value: "SAR \(fmtCurrency(totalPrice))",
                    color: primaryTeal,
                    bold: true
                )
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(softTeal.opacity(0.35))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(softTeal, lineWidth: 1)
            )
        }
        .padding(.top, 12)
        .animation(.easeInOut(duration: 0.25), value: totalPrice)
        .animation(.easeInOut(duration: 0.25), value: weight)
        .animation(.easeInOut(duration: 0.25), value: selectedKarat.id)
    }

    // MARK: - Small Components
    private func karatChip(_ option: KaratOption, title: String) -> some View {
        let isSelected = selectedKarat == option

        return Button {
            selectedKarat = option
        } label: {
            Text(title)
                .font(.appBody(.bold))
                .foregroundColor(isSelected ? .white : primaryTeal)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(isSelected ? primaryTeal : softTeal)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.maincolor), lineWidth: 0.2))
        }
        .buttonStyle(.plain)
    }

    private func breakdownRow(label: String, value: String, color: Color, bold: Bool = false) -> some View {
        HStack {
            Text(value)
                .font(bold ? .appTitle3(.bold) : .appBody(.semibold))
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            Text(label)
                .font(bold ? .appTitle3(.bold) : .appBody(.semibold))
                .foregroundColor(bold ? primaryTeal : primaryTeal.opacity(0.75))
                .multilineTextAlignment(.trailing)
        }
    }

    // MARK: - Helpers
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
