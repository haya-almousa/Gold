//
//  OnboardingPage.swift
//  Gold
//
//  Created by Rana Alqubaly on 01/12/1447 AH.
//

internal import SwiftUI

private struct OnboardingPage {
    let color: Color
    let title: String
    let symbol: String
    let symbolColor: Color


}

private let pages: [OnboardingPage] = [
    OnboardingPage(color: Color("maincolor"),     title: "تابع سعر الذهب\nلحظة بلحظة",          symbol: "chart.line.uptrend.xyaxis",                    symbolColor: Color("Light gold")),
    OnboardingPage(color: Color("Lightest blue"), title: "أضف ذهباً بكل\nسهولة وبدون تعقيد",    symbol: "bag.badge.plus",              symbolColor: Color("Gold")),
    OnboardingPage(color: Color("Light gold"),    title: "قارن أسعار الذهب\nواختار الأفضل",     symbol: "arrow.up.left.arrow.down.right",    symbolColor: Color("maincolor"))
]

struct OnboardingView: View {
    @State private var currentPage = 0
    var onFinished: () -> Void

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottom) {
                Color("background").ignoresSafeArea()

                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        pageContent(page: pages[index], geo: geo)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.35), value: currentPage)
                .environment(\.layoutDirection, .rightToLeft) // reverses swipe direction

                VStack(spacing: 24) {
                    dotsIndicator
                    nextButton
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
        }
        .ignoresSafeArea(edges: .top)
    }

    private func pageContent(page: OnboardingPage, geo: GeometryProxy) -> some View {
        ZStack(alignment: .top) {
            Color("background").ignoresSafeArea()

            // fills status bar area with blob color
            page.color
                .frame(maxWidth: .infinity)
                .frame(height: geo.safeAreaInsets.top + 1)
                .ignoresSafeArea(edges: .top)

            // blob circle
            Circle()
                .fill(page.color)
                .frame(width: geo.size.width * 1.4, height: geo.size.width * 1.4)
                .position(x: geo.size.width / 2,
                          y: geo.safeAreaInsets.top + geo.size.width * 0.3)
            
            // symbol inside the circle
            Image(systemName: page.symbol)
                .font(.system(size: 150, weight: .bold))
                .foregroundColor(page.symbolColor)
                .position(x: geo.size.width / 2,
                          y: 225)

            // nav row
            HStack {
                // LEFT: تخطى (hidden on last page)
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation { currentPage = pages.count - 1 }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 13, weight: .semibold))
                            Text("تخطى")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(.black)
                    }
                }

                Spacer()

                // RIGHT: رجوع (only from page 2 onward)
                if currentPage > 0 {
                    Button {
                        withAnimation { currentPage -= 1 }
                    } label: {
                        HStack(spacing: 4) {
                            Text("رجوع")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .foregroundColor(.black)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, geo.safeAreaInsets.top + 16)
            // title
            VStack(spacing: 0) {
                Spacer()
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 225)
            }
        }
        .environment(\.layoutDirection, .leftToRight) // cancel RTL inside each page
    }

    // dots: page 0 on right, page 2 on left
    private var dotsIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages.indices.reversed(), id: \.self) { i in
                Circle()
                    .fill(i == currentPage ? Color("maincolor") : Color("maincolor").opacity(0.25))
                    .frame(width: i == currentPage ? 10 : 7, height: i == currentPage ? 10 : 7)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }

    private var nextButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation { currentPage += 1 }
            } else {
                onFinished()
            }
        } label: {
            Text("التالي")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color("background"))
                .frame(maxWidth: 250)
                .frame(height: 45)
                .background(Color("maincolor"))
                .cornerRadius(25)
        }
    }
}

#Preview {
    OnboardingView {
        print("Onboarding finished")
    }
}
