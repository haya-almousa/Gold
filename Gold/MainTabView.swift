internal import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    @StateObject private var dashboardVM = DashboardViewModel()

    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView(viewModel: dashboardVM)
                    .tag(AppTab.home)
                    .toolbar(.hidden, for: .tabBar)
                ComparisonListView(selectedTab: $selectedTab)
                    .tag(AppTab.comparison)
                    .toolbar(.hidden, for: .tabBar)
                NavigationStack {
                    GoldCalculatorView(showBackButton: false)
                }
                    .tag(AppTab.calculator)
                    .toolbar(.hidden, for: .tabBar)
                TajouriView(dashboardVM: dashboardVM)
                    .tag(AppTab.tojory)
                    .toolbar(.hidden, for: .tabBar)
                    .environmentObject(AuthenticationManager.shared)
            }

            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tojoryTabItem
            Spacer()
            comparisonTabItem
            Spacer()
            calculatorTabItem
            Spacer()
            homeTabItem
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 20, x: 0, y: 6)
        )
        .padding(.horizontal, 15)
        .padding(.bottom, 5)
    }

    private var tojoryTabItem: some View {
        let active = selectedTab == .tojory
        return Button { selectedTab = .tojory } label: {
            VStack(spacing: 4) {
                VaultIcon()
                    .fill(active ? Color("maincolor") : Color(.navy).opacity(0.3))
                    .frame(width: 26, height: 26)
                Text("الخزنة")
                    .font(.appCaption(active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
            }
            .padding(.horizontal, active ? 14 : 0)
            .padding(.vertical, active ? 7 : 0)
            .background(
                active
                    ? AnyView(RoundedRectangle(cornerRadius: 16).fill(Color("Lightest blue").opacity(0.6)))
                    : AnyView(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var homeTabItem: some View {
        let active = selectedTab == .home
        return Button { selectedTab = .home } label: {
            VStack(spacing: 4) {
                GoldBarsIcon()
                    .fill(active ? Color("maincolor") : Color(.navy).opacity(0.3))
                    .frame(width: 26, height: 26)
                Text("اليوم")
                    .font(.appCaption(active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
            }
            .padding(.horizontal, active ? 14 : 0)
            .padding(.vertical, active ? 7 : 0)
            .background(
                active
                    ? AnyView(RoundedRectangle(cornerRadius: 16).fill(Color("Lightest blue").opacity(0.6)))
                    : AnyView(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var comparisonTabItem: some View {
        let active = selectedTab == .comparison
        return Button { selectedTab = .comparison } label: {
            VStack(spacing: 4) {
                Image("ComparisonIcon2")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
                Text("المقارنة")
                    .font(.appCaption(active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
            }
            .padding(.horizontal, active ? 14 : 0)
            .padding(.vertical, active ? 7 : 0)
            .background(
                active
                    ? AnyView(RoundedRectangle(cornerRadius: 16).fill(Color("Lightest blue").opacity(0.6)))
                    : AnyView(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private var calculatorTabItem: some View {
        let active = selectedTab == .calculator
        return Button { selectedTab = .calculator } label: {
            VStack(spacing: 4) {
                Image("CalculatorIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
                Text("الحاسبة")
                    .font(.appCaption(active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
            }
            .padding(.horizontal, active ? 14 : 0)
            .padding(.vertical, active ? 7 : 0)
            .background(
                active
                    ? AnyView(RoundedRectangle(cornerRadius: 16).fill(Color("Lightest blue").opacity(0.6)))
                    : AnyView(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }

    private func tabItem(tab: AppTab, symbol: String, title: String) -> some View {
        let active = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.appTitle3(active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
                Text(title)
                    .font(.appCaption(active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
            }
            .padding(.horizontal, active ? 14 : 0)
            .padding(.vertical, active ? 7 : 0)
            .background(
                active
                    ? AnyView(RoundedRectangle(cornerRadius: 16).fill(Color("Lightest blue").opacity(0.6)))
                    : AnyView(Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Vault Icon Shape

private struct VaultIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 209.0
        let sy = rect.height / 211.0
        var path = Path()

        // Vault body
        path.move(to: CGPoint(x: 176.34 * sx, y: 32.97 * sy))
        path.addLine(to: CGPoint(x: 32.66 * sx, y: 32.97 * sy))
        path.addCurve(to: CGPoint(x: 19.59 * sx, y: 46.16 * sy),
                      control1: CGPoint(x: 25.44 * sx, y: 32.97 * sy),
                      control2: CGPoint(x: 19.59 * sx, y: 38.87 * sy))
        path.addLine(to: CGPoint(x: 19.59 * sx, y: 158.25 * sy))
        path.addCurve(to: CGPoint(x: 32.66 * sx, y: 171.44 * sy),
                      control1: CGPoint(x: 19.59 * sx, y: 165.53 * sy),
                      control2: CGPoint(x: 25.44 * sx, y: 171.44 * sy))
        path.addLine(to: CGPoint(x: 45.72 * sx, y: 171.44 * sy))
        path.addLine(to: CGPoint(x: 45.72 * sx, y: 184.63 * sy))
        path.addCurve(to: CGPoint(x: 52.25 * sx, y: 191.22 * sy),
                      control1: CGPoint(x: 45.72 * sx, y: 188.27 * sy),
                      control2: CGPoint(x: 48.64 * sx, y: 191.22 * sy))
        path.addCurve(to: CGPoint(x: 58.78 * sx, y: 184.63 * sy),
                      control1: CGPoint(x: 55.86 * sx, y: 191.22 * sy),
                      control2: CGPoint(x: 58.78 * sx, y: 188.27 * sy))
        path.addLine(to: CGPoint(x: 58.78 * sx, y: 171.44 * sy))
        path.addLine(to: CGPoint(x: 150.22 * sx, y: 171.44 * sy))
        path.addLine(to: CGPoint(x: 150.22 * sx, y: 184.63 * sy))
        path.addCurve(to: CGPoint(x: 156.75 * sx, y: 191.22 * sy),
                      control1: CGPoint(x: 150.22 * sx, y: 188.27 * sy),
                      control2: CGPoint(x: 153.14 * sx, y: 191.22 * sy))
        path.addCurve(to: CGPoint(x: 163.28 * sx, y: 184.63 * sy),
                      control1: CGPoint(x: 160.36 * sx, y: 191.22 * sy),
                      control2: CGPoint(x: 163.28 * sx, y: 188.27 * sy))
        path.addLine(to: CGPoint(x: 163.28 * sx, y: 171.44 * sy))
        path.addLine(to: CGPoint(x: 176.34 * sx, y: 171.44 * sy))
        path.addCurve(to: CGPoint(x: 189.41 * sx, y: 158.25 * sy),
                      control1: CGPoint(x: 183.56 * sx, y: 171.44 * sy),
                      control2: CGPoint(x: 189.41 * sx, y: 165.53 * sy))
        path.addLine(to: CGPoint(x: 189.41 * sx, y: 46.16 * sy))
        path.addCurve(to: CGPoint(x: 176.34 * sx, y: 32.97 * sy),
                      control1: CGPoint(x: 189.41 * sx, y: 38.87 * sy),
                      control2: CGPoint(x: 183.56 * sx, y: 32.97 * sy))
        path.closeSubpath()

        // Lock handle bar (cutout)
        path.move(to: CGPoint(x: 169.81 * sx, y: 112.09 * sy))
        path.addLine(to: CGPoint(x: 146.21 * sx, y: 112.09 * sy))
        path.addCurve(to: CGPoint(x: 114.27 * sx, y: 134.99 * sy),
                      control1: CGPoint(x: 142.89 * sx, y: 126.82 * sy),
                      control2: CGPoint(x: 129.13 * sx, y: 136.67 * sy))
        path.addCurve(to: CGPoint(x: 88.16 * sx, y: 105.5 * sy),
                      control1: CGPoint(x: 99.40 * sx, y: 133.30 * sy),
                      control2: CGPoint(x: 88.16 * sx, y: 120.60 * sy))
        path.addCurve(to: CGPoint(x: 114.27 * sx, y: 76.01 * sy),
                      control1: CGPoint(x: 88.16 * sx, y: 90.40 * sy),
                      control2: CGPoint(x: 99.40 * sx, y: 77.70 * sy))
        path.addCurve(to: CGPoint(x: 146.21 * sx, y: 98.91 * sy),
                      control1: CGPoint(x: 129.13 * sx, y: 74.33 * sy),
                      control2: CGPoint(x: 142.89 * sx, y: 84.18 * sy))
        path.addLine(to: CGPoint(x: 169.81 * sx, y: 98.91 * sy))
        path.addCurve(to: CGPoint(x: 176.34 * sx, y: 105.5 * sy),
                      control1: CGPoint(x: 173.42 * sx, y: 98.91 * sy),
                      control2: CGPoint(x: 176.34 * sx, y: 101.86 * sy))
        path.addCurve(to: CGPoint(x: 169.81 * sx, y: 112.09 * sy),
                      control1: CGPoint(x: 176.34 * sx, y: 109.14 * sy),
                      control2: CGPoint(x: 173.42 * sx, y: 112.09 * sy))
        path.closeSubpath()

        // Inner dial circle
        path.move(to: CGPoint(x: 133.89 * sx, y: 105.5 * sy))
        path.addCurve(to: CGPoint(x: 117.56 * sx, y: 121.98 * sy),
                      control1: CGPoint(x: 133.89 * sx, y: 114.60 * sy),
                      control2: CGPoint(x: 126.58 * sx, y: 121.98 * sy))
        path.addCurve(to: CGPoint(x: 101.23 * sx, y: 105.5 * sy),
                      control1: CGPoint(x: 108.54 * sx, y: 121.98 * sy),
                      control2: CGPoint(x: 101.23 * sx, y: 114.60 * sy))
        path.addCurve(to: CGPoint(x: 117.56 * sx, y: 89.02 * sy),
                      control1: CGPoint(x: 101.23 * sx, y: 96.40 * sy),
                      control2: CGPoint(x: 108.54 * sx, y: 89.02 * sy))
        path.addCurve(to: CGPoint(x: 129.11 * sx, y: 93.84 * sy),
                      control1: CGPoint(x: 121.89 * sx, y: 89.02 * sy),
                      control2: CGPoint(x: 126.05 * sx, y: 90.75 * sy))
        path.addCurve(to: CGPoint(x: 133.89 * sx, y: 105.5 * sy),
                      control1: CGPoint(x: 132.17 * sx, y: 96.94 * sy),
                      control2: CGPoint(x: 133.89 * sx, y: 101.13 * sy))
        path.closeSubpath()

        return path
    }
}

// MARK: - Gold Bars Icon Shape

private struct GoldBarsIcon: Shape {
    func path(in rect: CGRect) -> Path {
        let sx = rect.width / 36.0
        let sy = rect.height / 36.0
        var path = Path()

        // Left gold bar
        path.move(to: CGPoint(x: 1.5 * sx, y: 33 * sy))
        path.addLine(to: CGPoint(x: 3.75 * sx, y: 25.5 * sy))
        path.addLine(to: CGPoint(x: 14.25 * sx, y: 25.5 * sy))
        path.addLine(to: CGPoint(x: 16.5 * sx, y: 33 * sy))
        path.closeSubpath()

        // Right gold bar
        path.move(to: CGPoint(x: 19.5 * sx, y: 33 * sy))
        path.addLine(to: CGPoint(x: 21.75 * sx, y: 25.5 * sy))
        path.addLine(to: CGPoint(x: 32.25 * sx, y: 25.5 * sy))
        path.addLine(to: CGPoint(x: 34.5 * sx, y: 33 * sy))
        path.closeSubpath()

        // Top gold bar
        path.move(to: CGPoint(x: 9 * sx, y: 22.5 * sy))
        path.addLine(to: CGPoint(x: 11.25 * sx, y: 15 * sy))
        path.addLine(to: CGPoint(x: 21.75 * sx, y: 15 * sy))
        path.addLine(to: CGPoint(x: 24 * sx, y: 22.5 * sy))
        path.closeSubpath()

        // Sparkle
        path.move(to: CGPoint(x: 34.5 * sx, y: 9.075 * sy))
        path.addLine(to: CGPoint(x: 28.71 * sx, y: 10.71 * sy))
        path.addLine(to: CGPoint(x: 27.075 * sx, y: 16.5 * sy))
        path.addLine(to: CGPoint(x: 25.44 * sx, y: 10.71 * sy))
        path.addLine(to: CGPoint(x: 19.65 * sx, y: 9.075 * sy))
        path.addLine(to: CGPoint(x: 25.44 * sx, y: 7.44 * sy))
        path.addLine(to: CGPoint(x: 27.075 * sx, y: 1.65 * sy))
        path.addLine(to: CGPoint(x: 28.71 * sx, y: 7.44 * sy))
        path.closeSubpath()

        return path
    }
}

#Preview {
    MainTabView()
}
