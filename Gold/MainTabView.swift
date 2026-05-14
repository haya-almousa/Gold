internal import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(AppTab.home)
                    .toolbar(.hidden, for: .tabBar)
                ComparisonListView(selectedTab: $selectedTab)
                    .tag(AppTab.comparison)
                    .toolbar(.hidden, for: .tabBar)
                EducationView(selectedTab: $selectedTab)
                    .tag(AppTab.education)
                    .toolbar(.hidden, for: .tabBar)
                TojoryView(selectedTab: $selectedTab)
                    .tag(AppTab.tojory)
                    .toolbar(.hidden, for: .tabBar)
            }

            customTabBar
        }
    }
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(tab: .tojory, symbol: "briefcase.fill", title: "التجوري")
            Spacer()
            tabItem(tab: .education, symbol: "book.closed.fill", title: "تعلم")
            Spacer()
            tabItem(tab: .comparison, symbol: "bookmark.fill", title: "المقارنة")
            Spacer()
            tabItem(tab: .home, symbol: "house.fill", title: "اليوم")
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
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }

    private func tabItem(tab: AppTab, symbol: String, title: String) -> some View {
        let active = selectedTab == tab
        return Button { selectedTab = tab } label: {
            VStack(spacing: 4) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: active ? .semibold : .regular))
                    .foregroundColor(active ? Color("maincolor") : Color(.navy).opacity(0.3))
                Text(title)
                    .font(.system(size: 11, weight: active ? .semibold : .regular))
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
