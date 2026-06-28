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
                Image("TojoryIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
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
                Image("HomeIcon")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 26, height: 26)
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
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

#Preview {
    MainTabView()
}
