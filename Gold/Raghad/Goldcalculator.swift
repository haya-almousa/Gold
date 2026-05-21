//
//  Goldcalculator.swift
//  Gold
//
//  Created by Haya Almousa on 2/12/1447 AH.
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

    // MARK: - State
    @State private var weightText: String = ""
    @State private var weight: Double = 0
    @State private var selectedKarat: KaratOption = .k18
    @State private var manufacturingFeeText: String = ""
    @State private var manufacturingFee: Double = 0
    @FocusState private var focusedField: Field?

    enum Field { case weight, fee }

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
        case k24 = "24 قيراط (999)"
        case k22 = "22 قيراط (916)"
        case k21 = "21 قيراط (875)"
        case k18 = "18 قيراط (750)"
        case k14 = "14 قيراط (585)"
        case k10 = "10 قيراط (417)"

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
                    manufacturingFeeSection
                    totalSection
                    Spacer(minLength: 16)
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
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

    // MARK: - Layout Sections
    private var topBar: some View {
        HStack {
            if let back = onBack {
                Button(action: back) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("رجوع")
                    }
                    .font(.appCallout(.semibold))
                    .foregroundColor(primaryTeal)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("حاسبة الذهب")
                .font(.appTitle(.bold))
                .foregroundColor(.black)
                .minimumScaleFactor(0.6)
        }
        .padding(.top, 40)
    }

    private var karatSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("العيار")
                .font(.appTitle2(.bold))
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
                .font(.appTitle2(.bold))
                .foregroundColor(primaryTeal)

            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(softTeal)
                    .frame(height: 48)

                if weightText.isEmpty {
                    Text("مثال:5.5")
                        .font(.appTitle3(.semibold))
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
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.maincolor), lineWidth: 0.2))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var manufacturingFeeSection: some View {
        VStack(alignment: .trailing, spacing: 10) {
            Text("المصنعية*")
                .font(.appTitle2(.bold))
                .foregroundColor(primaryTeal)

            ZStack(alignment: .trailing) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(softTeal)
                    .frame(height: 48)

                if manufacturingFeeText.isEmpty {
                    Text("مثال:10")
                        .font(.appTitle3(.semibold))
                        .foregroundColor(secondaryTeal.opacity(0.75))
                        .padding(.horizontal, 18)
                        .allowsHitTesting(false)
                }

                TextField("", text: $manufacturingFeeText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .font(.appTitle3(.semibold))
                    .foregroundColor(primaryTeal)
                    .padding(.horizontal, 18)
                    .focused($focusedField, equals: .fee)
                    .onChange(of: manufacturingFeeText) {
                        let filtered = manufacturingFeeText.filter { $0.isNumber || $0 == "." }
                        if filtered != manufacturingFeeText { manufacturingFeeText = filtered }
                        manufacturingFee = Double(filtered) ?? 0
                    }
            }
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.maincolor), lineWidth: 0.2))
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }

    private var totalSection: some View {
        VStack(spacing: 8) {
            Text("إجمالي السعر التقديري")
                .font(.appTitle2(.bold))
                .foregroundColor(mutedGold)

            Text("SAR \(fmtCurrency(totalValueSAR))")
                .font(.appTitle(.heavy))
                .foregroundColor(primaryTeal)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .animation(.easeInOut(duration: 0.25), value: totalValueSAR)
        }
        .padding(.top, 28)
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

    // MARK: - Helpers
    func breakdownRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
    }

    func stepperButtons(increment: @escaping () -> Void, decrement: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Button(action: increment) {
                Image(systemName: "chevron.up")
                    .font(.appCaption(.semibold))
                    .foregroundColor(secondaryTeal)
                    .frame(width: 28, height: 18)
            }
            Button(action: decrement) {
                Image(systemName: "chevron.down")
                    .font(.appCaption(.semibold))
                    .foregroundColor(secondaryTeal)
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
