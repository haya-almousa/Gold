//
//  DashboardView.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//jjjjلازال

internal import SwiftUI
import Charts

// MARK: - KaratOption

private enum KaratOption: String {
    case k24 = "24k"
    case k21 = "21k"
    case k18 = "18k"
}

// MARK: - Dashboard Colors

private enum DashboardColors {
    static let goldMain = Color(red: 0.96, green: 0.82, blue: 0.38)
    static let warmLight = Color(red: 0.93, green: 0.85, blue: 0.65)
    static let mutedTealText = Color(red: 0.41, green: 0.51, blue: 0.52)
    static let quickActionBackground = Color(red: 0.76, green: 0.84, blue: 0.85)
    static let goldValue = Color(red: 0.88, green: 0.74, blue: 0.30)
    static let progressTrack = Color(red: 0.79, green: 0.79, blue: 0.81)
    static let progressFill = Color(red: 0.04, green: 0.48, blue: 0.52)
    static let secondaryGray = Color(red: 0.69, green: 0.69, blue: 0.70)
    static let cardLightBackground = Color(red: 0.95, green: 0.95, blue: 0.96)
    static let cardBorder = Color(red: 0.89, green: 0.89, blue: 0.91)
    static let nisabBadge = Color(red: 0.85, green: 0.64, blue: 0.00)
    static let zakatBackground = Color(red: 0.93, green: 0.90, blue: 0.66)
    static let activeTab = Color(red: 0.22, green: 0.58, blue: 0.61)
    static let inactiveTab = Color(red: 0.60, green: 0.60, blue: 0.62)
    static let liveDot = Color(red: 0.35, green: 0.95, blue: 0.75)
    static let liveText = Color(red: 0.43, green: 0.94, blue: 0.78)
    static let liveBackground = Color(red: 0.06, green: 0.56, blue: 0.53)
    static let karatSelected = Color(red: 0.79, green: 0.66, blue: 0.30)
    static let karatUnselected = Color(red: 0.30, green: 0.63, blue: 0.65)
}

// MARK: - DashboardView

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @ObservedObject private var authManager = AuthenticationManager.shared
    @State private var selectedKarat: KaratOption = .k24
    @Environment(\.scenePhase) private var scenePhase

    @MainActor
    init(viewModel: DashboardViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DashboardViewModel())
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let width = geo.size.width
                let scale = min(max(width / 390, 0.92), 1.0)

                ZStack {
                    Color("background").ignoresSafeArea()

                    VStack(spacing: 0) {

                        // MARK: - الهيدر الأخضر ثابت مثل صفحة المقارنة
                        DashboardTopPriceCard(
                            scale: scale,
                            topInset: geo.safeAreaInsets.top,
                            greetingText: greetingText,
                            price: displayedPrice,
                            chartSamples: viewModel.chart24KSamples,
                            karatMultiplier: karatMultiplier,
                            lastUpdatedText: viewModel.lastUpdatedText,
                            selectedKarat: $selectedKarat
                        )

                        // MARK: - المحتوى المتحرك فقط
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 14 * scale) {

                                DashboardPortfolioZakatCard(
                                    scale: scale,
                                    portfolioValue: viewModel.formattedPortfolioValueToday,
                                    weeklyChange: viewModel.formattedWeeklyPortfolioChange,
                                    weeklyChangeIsPositive: viewModel.weeklyPortfolioChangeIsPositive,
                                    gramsProgress: viewModel.totalGramsProgressToNisab,
                                    totalGrams: viewModel.formattedTotalTojoryGrams,
                                    zakatDueText: viewModel.formattedZakatDueText,
                                    zakatStatusText: viewModel.zakatStatusText,
                                    nisabStatusText: viewModel.nisabStatusText,
                                    meetsNisab: viewModel.meetsNisab
                                )
                                .padding(.horizontal, 16 * scale)

                                Spacer(minLength: 0)
                            }
                            .padding(.top, 14 * scale)
                            .padding(.bottom, 92 * scale)
                        }
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
            .toolbar(.hidden, for: .navigationBar)
        }
        .refreshable { await viewModel.refreshManually() }
        .preferredColorScheme(.light)
        .task { viewModel.start() }
        .onDisappear { viewModel.stop() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.start()
                Task { await viewModel.refreshOnActive() }
            } else if newPhase == .background {
                viewModel.stop()
            }
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour >= 5 && hour < 12 { return "صباح الخير ☀️" }
        else if hour >= 12 && hour < 17 { return "مساء الخير 🌤️" }
        else { return "مساء الخير 🌙" }
    }

    private var displayedPrice: String {
        switch selectedKarat {
        case .k24: viewModel.formatted24K
        case .k21: viewModel.formatted21K
        case .k18: viewModel.formatted18K
        }
    }

    private var karatMultiplier: Double {
        switch selectedKarat {
        case .k24: return 1.0
        case .k21: return 21.0 / 24.0
        case .k18: return 18.0 / 24.0
        }
    }
}


// MARK: - Top Price Card

private struct DashboardTopPriceCard: View {
    let scale: CGFloat
    let topInset: CGFloat
    let greetingText: String
    let price: String
    let chartSamples: [GoldChartSample]
    let karatMultiplier: Double
    let lastUpdatedText: String
    @Binding var selectedKarat: KaratOption
    @State private var selectedDate: Date?

    var body: some View {
        VStack(spacing: 11 * scale) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(greetingText)
                        .font(.appSubheadline(.medium))
                        .foregroundStyle(DashboardColors.warmLight)

                    Spacer().frame(height: 12 * scale)

                    Text("سعر الذهب اليوم")
                        .font(.appSubheadline(.semibold))
                        .foregroundStyle(DashboardColors.warmLight)
                        .padding(.bottom, -12)
                }

                Spacer()

                liveBadge
            }

            HStack(alignment: .firstTextBaseline, spacing: 8 * scale) {
                Text(price)
                    .font(.system(size: 40 * scale, weight: .heavy))
                    .foregroundStyle(DashboardColors.goldMain)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("ر.س/ج")
                    .font(.appFootnote(.bold))
                    .foregroundStyle(DashboardColors.warmLight)

                Spacer()
            }

            InteractiveGoldChart(
                samples: chartSamples,
                karatMultiplier: karatMultiplier,
                scale: scale,
                selectedDate: $selectedDate
            )

            HStack {
                if let selectedDate,
                   let closest = chartSamples.min(by: {
                       abs($0.timestamp.timeIntervalSince(selectedDate)) < abs($1.timestamp.timeIntervalSince(selectedDate))
                   }) {
                    let selectedPrice = closest.price24KPerGramSAR * karatMultiplier
                    HStack(spacing: 6 * scale) {
                        Text(String(format: "%.2f", selectedPrice) + " ر.س/ج")
                            .font(.appCaption(.bold))
                            .foregroundStyle(DashboardColors.goldMain)
                        Text("•")
                            .foregroundStyle(DashboardColors.warmLight.opacity(0.5))
                        Text(formatChartTime(closest.timestamp))
                            .font(.appCaption(.medium))
                            .foregroundStyle(DashboardColors.warmLight)
                    }
                } else {
                    Text(lastUpdatedText)
                        .font(.appFootnote(.semibold))
                        .foregroundStyle(DashboardColors.warmLight)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer()

                HStack(spacing: 8 * scale) {
                    karatPill(.k18)
                    karatPill(.k21)
                    karatPill(.k24)
                }
            }
        }
        .padding(.horizontal, 16 * scale)
        .padding(.top, 12 * scale)
        .padding(.bottom, 12 * scale)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 34 * scale,
                bottomTrailingRadius: 34 * scale,
                topTrailingRadius: 0
            )
                .fill(Color("maincolor"))
                .padding(.top, -(topInset + 50))
        )
        .frame(maxWidth: .infinity)
    }

    private var liveBadge: some View {
        HStack(spacing: 7 * scale) {
            Circle()
                .fill(DashboardColors.liveDot)
                .frame(width: 8 * scale, height: 8 * scale)

            Text("مباشر")
                .font(.appSubheadline(.bold))
                .foregroundStyle(DashboardColors.liveText)
                
        }
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 3 * scale)
        .background(Capsule().fill(DashboardColors.liveBackground))
    }

    private func formatChartTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        if Calendar.current.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else {
            formatter.dateFormat = "d MMM h:mm a"
        }
        return formatter.string(from: date)
    }

    private func karatPill(_ option: KaratOption) -> some View {
        let active = selectedKarat == option
        return Button {
            selectedKarat = option
        } label: {
            Text(option.rawValue)
                .font(.appCaption(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12 * scale)
                .padding(.vertical, 7 * scale)
                .background(Capsule().fill(active ? DashboardColors.karatSelected : DashboardColors.karatUnselected))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.darkGreen), lineWidth: 0.7))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Portfolio & Zakat Card

private struct DashboardPortfolioZakatCard: View {
    let scale: CGFloat
    let portfolioValue: String
    let weeklyChange: String
    let weeklyChangeIsPositive: Bool
    let gramsProgress: CGFloat
    let totalGrams: String
    let zakatDueText: String
    let zakatStatusText: String
    let nisabStatusText: String
    let meetsNisab: Bool

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("ye"))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color(.darkGold), lineWidth: 0.2)
                )

            VStack(spacing: 0) {
                portfolioSection
                if meetsNisab {
                    zakatSection
                }
            }
        }
        .padding(.top, 2 * scale)
    }

    private var portfolioSection: some View {
        VStack(alignment: .trailing, spacing: 8 * scale) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 2 * scale) {
                    Text("قيمة ذهبك اليوم")
                        .font(.appSubheadline(.bold))
                        .foregroundStyle(Color("maincolor"))

                    Text(portfolioValue)
                        .font(.appTitle(.heavy))
                        .foregroundStyle(DashboardColors.goldValue)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("التجوري")
                    .font(.appCaption(.bold))
                    .foregroundStyle(Color("maincolor"))
                    .padding(.horizontal, 10 * scale)
                    .padding(.vertical, 5 * scale)
                    .background(Capsule().fill(Color("maincolor").opacity(0.1)))
                    .overlay(Capsule().stroke(Color("maincolor").opacity(0.4), lineWidth: 0.8))
            }

            Text("\(weeklyChange) \(weeklyChangeIsPositive ? "▲" : "▼")")
                .font(.appCaption(.bold))
                .foregroundStyle(weeklyChangeIsPositive ? DashboardColors.activeTab : .red)
                .frame(maxWidth: .infinity, alignment: .leading)

            GeometryReader { pGeo in
                ZStack(alignment: .leading) {
                    Capsule().fill(DashboardColors.progressTrack)
                    Capsule()
                        .fill(DashboardColors.progressFill)
                        .frame(width: pGeo.size.width * gramsProgress)
                }
            }
            .frame(height: 8 * scale)

            Text(totalGrams)
                .font(.appCaption(.bold))
                .foregroundStyle(DashboardColors.secondaryGray)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(14 * scale)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color("Yellow"))
        )
    }

    private var zakatSection: some View {
        HStack {
            Text(nisabStatusText)
                .font(.appFootnote(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 10 * scale)
                .padding(.vertical, 5 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                        .fill(meetsNisab ? DashboardColors.nisabBadge : DashboardColors.inactiveTab)
                )
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.darkGold), lineWidth: 0.2))

            Spacer()

            HStack(spacing: 6 * scale) {
                VStack(alignment: .trailing, spacing: 1 * scale) {
                    Text(zakatStatusText)
                        .font(.appSubheadline(.bold))
                        .foregroundStyle(Color("maincolor"))

                    Text(zakatDueText)
                        .font(.appFootnote(.bold))
                        .foregroundStyle(Color("maincolor"))
                }

                Image(systemName: "moon.fill")
                    .font(.appBody(.semibold))
                    .foregroundStyle(Color("maincolor"))
                    .scaleEffect(x: -1, y: 1)
            }
        }
        .environment(\.layoutDirection, .leftToRight)
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 18 * scale)
    }
}

// MARK: - Interactive Chart

private struct InteractiveGoldChart: View {
    let samples: [GoldChartSample]
    let karatMultiplier: Double
    let scale: CGFloat
    @Binding var selectedDate: Date?

    private struct ChartPoint: Identifiable {
        var id: Date { date }
        let date: Date
        let price: Double
    }

    private var points: [ChartPoint] {
        samples.map {
            ChartPoint(date: $0.timestamp, price: $0.price24KPerGramSAR * karatMultiplier)
        }
    }

    private var selectedPoint: ChartPoint? {
        guard let selectedDate else { return nil }
        return points.min(by: {
            abs($0.date.timeIntervalSince(selectedDate)) < abs($1.date.timeIntervalSince(selectedDate))
        })
    }

    private var yDomain: ClosedRange<Double> {
        let prices = points.map(\.price)
        let minP = (prices.min() ?? 0) * 0.998
        let maxP = (prices.max() ?? 1) * 1.002
        return minP...maxP
    }

    var body: some View {
        if points.count >= 2 {
            chartView
        } else {
            Text("جاري تجميع البيانات...")
                .font(.appCaption(.medium))
                .foregroundStyle(DashboardColors.warmLight.opacity(0.6))
                .frame(height: 108 * scale)
                .frame(maxWidth: .infinity)
        }
    }

    private var chartView: some View {
        Chart {
            ForEach(points) { point in
                AreaMark(
                    x: .value("Time", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            DashboardColors.goldMain.opacity(0.30),
                            DashboardColors.goldMain.opacity(0.03)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                LineMark(
                    x: .value("Time", point.date),
                    y: .value("Price", point.price)
                )
                .foregroundStyle(DashboardColors.goldMain)
                .lineStyle(StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                .interpolationMethod(.catmullRom)
            }

            if let point = selectedPoint {
                RuleMark(x: .value("", point.date))
                    .foregroundStyle(DashboardColors.goldMain.opacity(0.5))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 3]))

                PointMark(
                    x: .value("", point.date),
                    y: .value("", point.price)
                )
                .foregroundStyle(DashboardColors.goldMain)
                .symbolSize(60)
                .annotation(position: .top, spacing: 4) {
                    Text(String(format: "%.2f", point.price))
                        .font(.appCaption(.bold))
                        .foregroundStyle(DashboardColors.goldMain)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color("maincolor").opacity(0.8))
                        )
                }
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: yDomain)
        .chartXSelection(value: $selectedDate)
        .chartScrollableAxes(.horizontal)
        .frame(height: 108 * scale)
    }
}

// MARK: - Preview

#Preview {
    DashboardView(viewModel: .preview)
}
