//
//  DashboardView.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel: DashboardViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var selectedTab: DashboardTab = .home

    @MainActor
    init(viewModel: DashboardViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? DashboardViewModel())
    }

    var body: some View {
        GeometryReader { geometry in
            let metrics = DashboardMetrics(screenSize: geometry.size)

            ZStack {
                dashboardBackground

                VStack(spacing: 0) {
                    topBar(metrics: metrics)

                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: metrics.sectionSpacing) {
                            heroSection(metrics: metrics)
                            marketTicker(metrics: metrics)
                            quickActionsSection(metrics: metrics)

                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal, 4)
                            }
                        }
                        .padding(.horizontal, metrics.horizontalPadding)
                        .padding(.top, metrics.contentTopPadding)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .refreshable {
                        await viewModel.refreshManually()
                    }

                    bottomNavigation(metrics: metrics)
                }

                VStack(spacing: metrics.iconStackSpacing) {
                    actionIcon(symbol: "bookmark", metrics: metrics)
                    actionIcon(symbol: "arrow.up.left.and.arrow.down.right", metrics: metrics)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, metrics.floatingIconsTopPadding)
                .padding(.trailing, metrics.floatingIconsTrailingPadding)
            }
        }
        .preferredColorScheme(.light)
        .task {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stop()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.start()
                Task {
                    await viewModel.refreshOnActive()
                }
            } else if newPhase == .background {
                viewModel.stop()
            }
        }
    }

    private var dashboardBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.99, green: 0.97, blue: 0.92),
                    Color(red: 0.96, green: 0.92, blue: 0.82),
                    Color(red: 0.98, green: 0.96, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(Color.white.opacity(0.8))
                .frame(width: 300, height: 300)
                .blur(radius: 26)
                .offset(x: 120, y: -260)

            Circle()
                .fill(Color.goldGlow.opacity(0.26))
                .frame(width: 250, height: 250)
                .blur(radius: 40)
                .offset(x: 115, y: -130)
        }
    }

    private func topBar(metrics: DashboardMetrics) -> some View {
        HStack {
            Text("الرئيسية")
                .font(.system(size: metrics.titleFont, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.ink)

            Spacer()
        }
        .padding(.horizontal, metrics.horizontalPadding)
        .padding(.top, metrics.topPadding)
        .padding(.bottom, metrics.topBarBottomPadding)
    }

    private func heroSection(metrics: DashboardMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.heroSpacing) {
            VStack(alignment: .leading, spacing: metrics.heroInnerSpacing) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)

                            Text("مباشر • 24 قيراط / جرام")
                                .font(.system(size: metrics.captionFont, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.secondaryInk)
                        }

                        if viewModel.isLoading && viewModel.quote == nil {
                            ProgressView()
                                .tint(Color.goldText)
                                .frame(height: metrics.priceBlockHeight, alignment: .leading)
                        } else {
                            Text("SAR \(viewModel.formatted24K)")
                                .font(.system(size: metrics.priceFont, weight: .bold, design: .serif))
                                .foregroundStyle(Color.goldText)
                                .contentTransition(.numericText())
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                        }

                        Text("≈ $\(viewModel.formattedUSDPerGram) USD")
                            .font(.system(size: metrics.valueCaptionFont, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.secondaryInk)

                        Text(viewModel.lastUpdatedText)
                            .font(.system(size: metrics.valueCaptionFont - 1, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondaryInk.opacity(0.8))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 6) {
                        HStack(spacing: 4) {
                            Image(systemName: trendIcon)
                                .font(.system(size: metrics.trendIconFont, weight: .bold))

                            Text(viewModel.formattedChangePercent)
                                .font(.system(size: metrics.changeFont, weight: .bold, design: .rounded))
                        }
                        .foregroundStyle(viewModel.changeColor)

                        Text("اليوم")
                            .font(.system(size: metrics.valueCaptionFont, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondaryInk)
                    }
                }

                HStack(spacing: metrics.karatSpacing) {
                    karatValue(title: "22K", value: viewModel.formatted22K, metrics: metrics)
                    karatValue(title: "21K", value: viewModel.formatted21K, metrics: metrics)
                    karatValue(title: "18K", value: viewModel.formatted18K, metrics: metrics)
                }
            }
            .padding(metrics.heroCardPadding)
            .background(
                RoundedRectangle(cornerRadius: metrics.heroCornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.9),
                                Color(red: 0.97, green: 0.94, blue: 0.86)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: metrics.heroCornerRadius, style: .continuous)
                            .stroke(Color.goldStroke.opacity(0.5), lineWidth: 1.2)
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 14, y: 8)
            )
        }
    }

    private func marketTicker(metrics: DashboardMetrics) -> some View {
        HStack(spacing: 10) {
            Text("22 قيراط / جرام")
                .foregroundStyle(Color.secondaryInk)

            Text("SAR \(viewModel.formatted22K)")
                .foregroundStyle(Color.goldText)

            Text(viewModel.formattedChangePercent)
                .foregroundStyle(viewModel.changeColor)

            Text("•")
                .foregroundStyle(Color.secondaryInk)

            Text("21 قيراط / جرام")
                .foregroundStyle(Color.secondaryInk)

            Text("SAR \(viewModel.formatted21K)")
                .foregroundStyle(Color.goldText)
        }
        .font(.system(size: metrics.tickerFont, weight: .bold, design: .rounded))
        .lineLimit(1)
        .minimumScaleFactor(0.75)
        .padding(.horizontal, 14)
        .padding(.vertical, metrics.tickerVerticalPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.goldBar.opacity(0.24))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.goldStroke.opacity(0.45), lineWidth: 1)
                )
        )
    }

    private func quickActionsSection(metrics: DashboardMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.actionsSpacing) {
            Text("إجراءات سريعة")
                .font(.system(size: metrics.captionFont, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondaryInk.opacity(0.8))

            HStack(spacing: metrics.cardSpacing) {
                quickActionCard(
                    title: "حاسبة الذهب",
                    subtitle: "احسب القيمة",
                    symbol: "building.columns",
                    metrics: metrics
                )

                quickActionCard(
                    title: "الزكاة",
                    subtitle: "تحقق من النصاب",
                    symbol: "star",
                    metrics: metrics
                )
            }

            portfolioCard(metrics: metrics)
        }
    }

    private func portfolioCard(metrics: DashboardMetrics) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.goldBar.opacity(0.28))
                    .frame(width: metrics.smallIconBox, height: metrics.smallIconBox)

                Image(systemName: "bag")
                    .font(.system(size: metrics.smallIconFont, weight: .semibold))
                    .foregroundStyle(Color.goldText)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("محفظتي")
                    .font(.system(size: metrics.portfolioTitleFont, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text("تابع ممتلكاتك")
                    .font(.system(size: metrics.cardSubtitleFont, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondaryInk)
            }

            Spacer()

            Image(systemName: "arrow.right")
                .font(.system(size: metrics.arrowFont, weight: .bold))
                .foregroundStyle(Color.secondaryInk)
        }
        .padding(metrics.portfolioPadding)
        .background(cardBackground)
    }

    private func quickActionCard(title: String, subtitle: String, symbol: String, metrics: DashboardMetrics) -> some View {
        VStack(alignment: .leading, spacing: metrics.quickCardInnerSpacing) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.goldBar.opacity(0.28))
                    .frame(width: metrics.smallIconBox, height: metrics.smallIconBox)

                Image(systemName: symbol)
                    .font(.system(size: metrics.smallIconFont, weight: .semibold))
                    .foregroundStyle(Color.goldText)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: metrics.cardTitleFont, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.system(size: metrics.cardSubtitleFont, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.secondaryInk)
            }
        }
        .frame(maxWidth: .infinity, minHeight: metrics.quickCardHeight, alignment: .topLeading)
        .padding(metrics.quickCardPadding)
        .background(cardBackground)
    }

    private func bottomNavigation(metrics: DashboardMetrics) -> some View {
        HStack {
            tabButton(tab: .profile, title: "الملف", symbol: "person", metrics: metrics)
            Spacer()
            tabButton(tab: .home, title: "الرئيسية", symbol: "house", metrics: metrics)
            Spacer()
            tabButton(tab: .calculate, title: "الحاسبة", symbol: "building.columns", metrics: metrics)
        }
        .padding(.horizontal, metrics.navHorizontalPadding)
        .padding(.top, metrics.navTopPadding)
        .padding(.bottom, metrics.navBottomPadding)
        .background(
            UnevenRoundedRectangle(
                topLeadingRadius: metrics.navCornerRadius,
                topTrailingRadius: metrics.navCornerRadius
            )
            .fill(Color(red: 0.97, green: 0.95, blue: 0.88))
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.goldStroke.opacity(0.3))
                    .frame(height: 1)
            }
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabButton(tab: DashboardTab, title: String, symbol: String, metrics: DashboardMetrics) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: metrics.tabSpacing) {
                ZStack {
                    if selectedTab == tab {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.goldHighlight, Color.goldText],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: metrics.selectedTabSize, height: metrics.selectedTabSize)
                            .shadow(color: Color.goldText.opacity(0.25), radius: 12, y: 8)
                    }

                    Image(systemName: symbol)
                        .font(.system(size: metrics.tabIconFont, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? Color.ink : Color.secondaryInk)
                }
                .frame(height: metrics.selectedTabSize)

                Text(title)
                    .font(.system(size: metrics.tabLabelFont, weight: .bold, design: .rounded))
                    .foregroundStyle(selectedTab == tab ? Color.goldText : Color.secondaryInk)
            }
        }
        .buttonStyle(.plain)
    }

    private func actionIcon(symbol: String, metrics: DashboardMetrics) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.goldBar.opacity(0.24))
                .frame(width: metrics.actionIconSize, height: metrics.actionIconSize)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.goldStroke.opacity(0.5), lineWidth: 1)
                )

            Image(systemName: symbol)
                .font(.system(size: metrics.actionIconFont, weight: .medium))
                .foregroundStyle(Color.goldText)
        }
    }

    private func karatValue(title: String, value: String, metrics: DashboardMetrics) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(title)
                .font(.system(size: metrics.captionFont, weight: .bold, design: .rounded))
                .foregroundStyle(Color.secondaryInk.opacity(0.75))

            Text(value)
                .font(.system(size: metrics.karatValueFont, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, metrics.karatVerticalPadding)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(red: 0.96, green: 0.94, blue: 0.88))
        )
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.88),
                        Color(red: 0.97, green: 0.94, blue: 0.87)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.goldStroke.opacity(0.38), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 12, y: 8)
    }

    private var trendIcon: String {
        let change = viewModel.quote?.changePercent ?? 0
        if change < 0 {
            return "arrow.down.right"
        }
        return "arrow.up.right"
    }
}

private struct DashboardMetrics {
    let screenSize: CGSize

    private var compactHeight: Bool {
        screenSize.height < 760
    }

    var horizontalPadding: CGFloat { compactHeight ? 14 : 18 }
    var topPadding: CGFloat { compactHeight ? 22 : 30 }
    var topBarBottomPadding: CGFloat { compactHeight ? 10 : 14 }
    var contentTopPadding: CGFloat { compactHeight ? 10 : 14 }
    var sectionSpacing: CGFloat { compactHeight ? 10 : 16 }
    var heroSpacing: CGFloat { compactHeight ? 4 : 6 }
    var iconStackSpacing: CGFloat { compactHeight ? 8 : 10 }
    var heroInnerSpacing: CGFloat { compactHeight ? 12 : 16 }
    var karatSpacing: CGFloat { compactHeight ? 8 : 10 }
    var actionsSpacing: CGFloat { compactHeight ? 10 : 12 }
    var cardSpacing: CGFloat { compactHeight ? 10 : 12 }
    var quickCardInnerSpacing: CGFloat { compactHeight ? 10 : 12 }
    var navHorizontalPadding: CGFloat { compactHeight ? 24 : 30 }
    var navTopPadding: CGFloat { compactHeight ? 8 : 12 }
    var navBottomPadding: CGFloat { compactHeight ? 10 : 16 }
    var tabSpacing: CGFloat { compactHeight ? 2 : 4 }

    var titleFont: CGFloat { compactHeight ? 22 : 25 }
    var captionFont: CGFloat { compactHeight ? 10 : 11 }
    var valueCaptionFont: CGFloat { compactHeight ? 11 : 13 }
    var priceFont: CGFloat { compactHeight ? 28 : 34 }
    var changeFont: CGFloat { compactHeight ? 18 : 22 }
    var trendIconFont: CGFloat { compactHeight ? 10 : 12 }
    var tickerFont: CGFloat { compactHeight ? 11 : 12 }
    var cardTitleFont: CGFloat { compactHeight ? 16 : 20 }
    var cardSubtitleFont: CGFloat { compactHeight ? 11 : 13 }
    var portfolioTitleFont: CGFloat { compactHeight ? 18 : 20 }
    var arrowFont: CGFloat { compactHeight ? 16 : 18 }
    var tabIconFont: CGFloat { compactHeight ? 16 : 18 }
    var tabLabelFont: CGFloat { compactHeight ? 8 : 9 }
    var actionIconFont: CGFloat { compactHeight ? 14 : 16 }
    var smallIconFont: CGFloat { compactHeight ? 15 : 17 }
    var karatValueFont: CGFloat { compactHeight ? 17 : 20 }

    var heroCardPadding: CGFloat { compactHeight ? 14 : 16 }
    var quickCardPadding: CGFloat { compactHeight ? 10 : 12 }
    var portfolioPadding: CGFloat { compactHeight ? 14 : 16 }
    var tickerVerticalPadding: CGFloat { compactHeight ? 10 : 12 }
    var karatVerticalPadding: CGFloat { compactHeight ? 10 : 14 }
    var floatingIconsTopPadding: CGFloat { compactHeight ? -28 : -20 }
    var floatingIconsTrailingPadding: CGFloat { compactHeight ? 16 : 20 }

    var actionIconSize: CGFloat { compactHeight ? 42 : 48 }
    var smallIconBox: CGFloat { compactHeight ? 38 : 42 }
    var selectedTabSize: CGFloat { compactHeight ? 40 : 46 }
    var quickCardHeight: CGFloat { compactHeight ? 64 : 78 }
    var priceBlockHeight: CGFloat { compactHeight ? 40 : 50 }

    var heroCornerRadius: CGFloat { compactHeight ? 24 : 28 }
    var navCornerRadius: CGFloat { compactHeight ? 22 : 26 }
}

private enum DashboardTab {
    case profile
    case home
    case calculate
}

extension Color {
    static let ink = Color(red: 0.19, green: 0.16, blue: 0.10)
    static let secondaryInk = Color(red: 0.45, green: 0.39, blue: 0.28)
    static let goldText = Color(red: 0.68, green: 0.53, blue: 0.18)
    static let goldHighlight = Color(red: 0.89, green: 0.76, blue: 0.39)
    static let goldGlow = Color(red: 0.92, green: 0.80, blue: 0.48)
    static let goldStroke = Color(red: 0.75, green: 0.63, blue: 0.34)
    static let goldBar = Color(red: 0.86, green: 0.76, blue: 0.50)
    static let profit = Color(red: 0.17, green: 0.60, blue: 0.40)
}

#Preview {
    DashboardView(viewModel: .preview)
}
