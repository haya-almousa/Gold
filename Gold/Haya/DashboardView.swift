//
//  DashboardView.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

internal import SwiftUI

struct DashboardView: View {
    private enum KaratOption: String {
        case k24 = "24k"
        case k21 = "21k"
        case k18 = "18k"
    }

    @StateObject private var viewModel: DashboardViewModel
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
                let height = geo.size.height
                let scale = min(max(min(width / 390, height / 844), 0.84), 1.0)

                ZStack(alignment: .bottom) {
                    Color("background")
                        .ignoresSafeArea()

                    VStack(spacing: 12 * scale) {
                        topPriceCard(scale: scale)
                            .padding(.horizontal, 0)
                            .padding(.top, -(geo.safeAreaInsets.top))

                        quickActionsSection(scale: scale)
                            .padding(.horizontal, 10 * scale)

                        portfolioAndZakatCard(scale: scale)
                            .padding(.horizontal, 10 * scale)

                        Spacer(minLength: 0)
                    }
                    .padding(.top, 0)
                    .padding(.bottom, 80)

                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .refreshable {
            await viewModel.refreshManually()
        }
        .navigationBarTitleDisplayMode(.inline)
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

    private func topPriceCard(scale: CGFloat) -> some View {
        VStack(spacing: 11 * scale) {
            HStack(alignment: .center) {
                VStack(alignment: .trailing, spacing: 4 * scale) {
                    Text("صباح الخير ☀️")
                        .font(.system(size: 15 * scale, weight: .medium))
                        .foregroundStyle(Self.warmLight)

                    Text("هياء!")
                        .font(.system(size: 44 * scale, weight: .bold))
                        .foregroundStyle(Self.goldMain)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }

                Spacer()

                liveBadge(scale: scale)
            }

            HStack(alignment: .firstTextBaseline, spacing: 8 * scale) {
                Text(displayedPrice)
                    .font(.system(size: 56 * scale, weight: .heavy))
                    .foregroundStyle(Self.goldMain)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text("ر.س/ج")
                    .font(.system(size: 24 * scale, weight: .bold))
                    .foregroundStyle(Self.warmLight)

                Spacer()

                Text("سعر الذهب اليوم")
                    .font(.system(size: 15 * scale, weight: .semibold))
                    .foregroundStyle(Self.warmLight)
            }

            ZStack(alignment: .bottomLeading) {
                GoldLineChartFillShape(values: displayedChartValues)
                    .fill(
                        LinearGradient(
                            colors: [Self.goldMain.opacity(0.30), Self.goldMain.opacity(0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 108 * scale)

                GoldLineChartShape(values: displayedChartValues)
                    .stroke(Self.goldMain, style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
                    .frame(height: 108 * scale)
            }

            HStack {
                HStack(spacing: 8 * scale) {
                    karatPill(.k24, scale: scale)
                    karatPill(.k21, scale: scale)
                    karatPill(.k18, scale: scale)
                }

                Spacer()

                Text(viewModel.lastUpdatedText)
                    .font(.system(size: 14 * scale, weight: .semibold))
                    .foregroundStyle(Self.warmLight)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
        }
        .padding(.horizontal, 16 * scale)
        .padding(.top, 22 * scale)
        .padding(.bottom, 12 * scale)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 34 * scale,
                bottomTrailingRadius: 34 * scale,
                topTrailingRadius: 0
            )
                .fill(Color("maincolor"))
        )
        .frame(maxWidth: .infinity)
    }

    private func quickActionsSection(scale: CGFloat) -> some View {
        VStack(alignment: .trailing, spacing: 13 * scale) {
            Text("الاجراءات السريعة")
                .font(.system(size: 24 * scale, weight: .bold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            NavigationLink {
                GoldCalculatorView()
            } label: {
                HStack(spacing: 12 * scale) {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 4 * scale) {
                        Text("حاسبة الذهب")
                            .font(.system(size: 20 * scale, weight: .bold))
                            .foregroundStyle(Color("maincolor"))

                        Text("احسب سعر الذهب فورياً مع الضريبة")
                            .font(.system(size: 13 * scale, weight: .semibold))
                            .foregroundStyle(Self.mutedTealText)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .multilineTextAlignment(.trailing)

                    ZStack {
                        Circle()
                            .fill(Color("maincolor"))
                            .frame(width: 66 * scale, height: 66 * scale)

                        VStack(spacing: 4 * scale) {
                            Image(systemName: "plus")
                            Image(systemName: "minus")
                        }
                        .font(.system(size: 20 * scale, weight: .bold))
                        .foregroundStyle(Color.white.opacity(0.95))
                    }
                }
                .environment(\.layoutDirection, .leftToRight)
                .padding(.horizontal, 16 * scale)
                .padding(.vertical, 15 * scale)
                .background(
                    RoundedRectangle(cornerRadius: 20 * scale, style: .continuous)
                        .fill(Self.quickActionBackground)
                )
            }
            .buttonStyle(.plain)
        }
    }

    private func portfolioAndZakatCard(scale: CGFloat) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .trailing, spacing: 12 * scale) {
                ZStack(alignment: .topTrailing) {
                    VStack(alignment: .trailing, spacing: 2 * scale) {
                        Text("قيمة ذهبك اليوم")
                            .font(.system(size: 20 * scale, weight: .bold))
                            .foregroundStyle(Color("maincolor"))

                        Text(viewModel.formattedPortfolioValueToday)
                            .font(.system(size: 50 * scale, weight: .heavy))
                            .foregroundStyle(Self.goldValue)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Text("التجوري")
                        .font(.system(size: 14 * scale, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12 * scale)
                        .padding(.vertical, 7 * scale)
                        .background(Capsule().fill(Color("maincolor")))
                }

                Text("\(viewModel.formattedWeeklyPortfolioChange) \(viewModel.weeklyPortfolioChangeIsPositive ? "▲" : "▼")")
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundStyle(viewModel.weeklyPortfolioChangeIsPositive ? Self.activeTab : .red)
                    .frame(maxWidth: .infinity, alignment: .leading)

                GeometryReader { pGeo in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Self.progressTrack)
                        Capsule()
                            .fill(Self.progressFill)
                            .frame(width: pGeo.size.width * viewModel.totalGramsProgressToNisab)
                    }
                }
                .frame(height: 11 * scale)

                Text(viewModel.formattedTotalTojoryGrams)
                    .font(.system(size: 14 * scale, weight: .bold))
                    .foregroundStyle(Self.secondaryGray)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(17 * scale)
            .background(
                RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                    .fill(Self.cardLightBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18 * scale, style: .continuous)
                            .stroke(Self.cardBorder, lineWidth: 1)
                    )
            )

            HStack {
                HStack(spacing: 8 * scale) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 22 * scale, weight: .semibold))
                        .foregroundStyle(Color("maincolor"))

                    VStack(alignment: .trailing, spacing: 2 * scale) {
                        Text("الزكاة مستحقة")
                            .font(.system(size: 22 * scale, weight: .bold))
                            .foregroundStyle(Color("maincolor"))

                        Text(viewModel.formattedZakatDueText)
                            .font(.system(size: 18 * scale, weight: .bold))
                            .foregroundStyle(Color("maincolor"))
                    }
                }
                .environment(\.layoutDirection, .leftToRight)

                Spacer()

                Text(viewModel.nisabStatusText)
                    .font(.system(size: 16 * scale, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12 * scale)
                    .padding(.vertical, 7 * scale)
                    .background(
                        RoundedRectangle(cornerRadius: 10 * scale, style: .continuous)
                            .fill(viewModel.meetsNisab ? Self.nisabBadge : Self.inactiveTab)
                    )
            }
            .environment(\.layoutDirection, .leftToRight)
            .padding(.horizontal, 16 * scale)
            .padding(.vertical, 14 * scale)
            .background(
                UnevenRoundedRectangle(bottomLeadingRadius: 18 * scale, bottomTrailingRadius: 18 * scale)
                    .fill(Self.zakatBackground)
            )
        }
    }

  

    

    private func liveBadge(scale: CGFloat) -> some View {
        HStack(spacing: 7 * scale) {
            Circle()
                .fill(Self.liveDot)
                .frame(width: 8 * scale, height: 8 * scale)

            Text("مباشر")
                .font(.system(size: 15 * scale, weight: .bold))
                .foregroundStyle(Self.liveText)
        }
        .padding(.horizontal, 12 * scale)
        .padding(.vertical, 6 * scale)
        .background(Capsule().fill(Self.liveBackground))
    }

    private func karatPill(_ option: KaratOption, scale: CGFloat) -> some View {
        let active = selectedKarat == option
        return Button {
            selectedKarat = option
        } label: {
            Text(option.rawValue)
                .font(.system(size: 12 * scale, weight: .bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 12 * scale)
                .padding(.vertical, 7 * scale)
                .background(Capsule().fill(active ? Self.karatSelected : Self.karatUnselected))
        }
        .buttonStyle(.plain)
    }

    private var displayedPrice: String {
        switch selectedKarat {
        case .k24:
            viewModel.formatted24K
        case .k21:
            viewModel.formatted21K
        case .k18:
            viewModel.formatted18K
        }
    }

    private var displayedChartValues: [Double] {
        let history = viewModel.chart24KHistory
        switch selectedKarat {
        case .k24:
            return history
        case .k21:
            return history.map { $0 * (21.0 / 24.0) }
        case .k18:
            return history.map { $0 * (18.0 / 24.0) }
        }
    }
}

private extension DashboardView {
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

private struct GoldLineChartShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let samples = normalizedSamples(from: values)
        guard samples.count > 1 else { return path }

        let mapped = samples.enumerated().map { index, value in
            let xProgress = CGFloat(index) / CGFloat(max(samples.count - 1, 1))
            let x = rect.minX + xProgress * rect.width
            let y = rect.maxY - CGFloat(value) * rect.height
            return CGPoint(x: x, y: y)
        }
        guard let first = mapped.first else { return path }

        path.move(to: first)
        for index in 1..<mapped.count {
            let previous = mapped[index - 1]
            let current = mapped[index]
            let mid = CGPoint(x: (previous.x + current.x) / 2, y: (previous.y + current.y) / 2)
            path.addQuadCurve(to: mid, control: previous)
            path.addQuadCurve(to: current, control: current)
        }

        return path
    }

    private func normalizedSamples(from values: [Double]) -> [Double] {
        let clampedValues: [Double]
        if values.count >= 2 {
            clampedValues = values
        } else if let single = values.first {
            clampedValues = [single, single]
        } else {
            clampedValues = [0.5, 0.5]
        }

        guard let minValue = clampedValues.min(), let maxValue = clampedValues.max() else {
            return Array(repeating: 0.5, count: clampedValues.count)
        }

        let spread = max(maxValue - minValue, 0.0001)
        return clampedValues.map { value in
            let normalized = (value - minValue) / spread
            return min(max(normalized * 0.70 + 0.15, 0.0), 1.0)
        }
    }
}

private struct GoldLineChartFillShape: Shape {
    let values: [Double]

    func path(in rect: CGRect) -> Path {
        var line = GoldLineChartShape(values: values).path(in: rect)
        line.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        line.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        line.closeSubpath()
        return line
    }
}

#Preview {
    DashboardView(viewModel: .preview)
}
