//
//  ComparisonListView.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI

struct ComparisonListView: View {
    @StateObject private var vm = ComparisonListViewModel()

    @State private var searchText:    String  = ""
    @State private var showSearch:    Bool    = false
    @State private var showFilter:    Bool    = false
    @State private var filterKarat:   Karat?  = nil

    private var filteredPieces: [GoldPiece] {
        vm.pieces.filter { piece in
            let matchesSearch = searchText.isEmpty
                || piece.name.localizedCaseInsensitiveContains(searchText)
                || piece.store.localizedCaseInsensitiveContains(searchText)
            let matchesKarat = filterKarat == nil || piece.karat == filterKarat
            return matchesSearch && matchesKarat
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        premiumBannerView

                        if !vm.pieces.isEmpty {
                            draftWarningView
                            filterSearchRow

                            if showSearch {
                                searchBar
                            }

                            if showFilter {
                                filterChips
                            }
                        }

                        if filteredPieces.isEmpty && !vm.pieces.isEmpty {
                            Text("لا توجد نتائج")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.navy).opacity(0.4))
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity)
                        } else if vm.pieces.isEmpty {
                            emptyStateView
                        }

                        ForEach(filteredPieces) { piece in
                            GoldItemCardView(
                                piece:    piece,
                                isBest:   piece.id == vm.bestPiece?.id && vm.pieces.count > 1,
                                onEdit:   { withAnimation { vm.beginEdit(piece: piece) } },
                                onDelete: { withAnimation { vm.deletePiece(id: piece.id) } }
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.pieces)
                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showSearch)
                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showFilter)
                }
            }

            bottomTabBar
        }
        .environment(\.layoutDirection, .rightToLeft)
        .sheet(isPresented: $vm.showForm, onDismiss: { vm.cancelForm() }) {
            AddGoldFormView(vm: vm)
                .environment(\.layoutDirection, .rightToLeft)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center) {
            Text("قائمة المقارنة")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.navy))
            Spacer()
            Button(action: { withAnimation { vm.toggleForm() } }) {
                ZStack {
                    Circle()
                        .fill(Color(.beige))
                        .frame(width: 46, height: 46)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(.navy))
                }
            }
        }
    }

    // MARK: - Premium Banner

    private var premiumBannerView: some View {
        HStack(spacing: 12) {
            // Trailing in RTL (left): try button
            Button(action: {}) {
                Text("جرب مجانا")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.navy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("background"))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color(.navy).opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            // Leading in RTL (right): text + sparkle
            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("فتح المقارنة بالكامل")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(.navy))
                    Text("تجربة مجانية لمدة 7 ايام - احفظ\nوقارن قطع الذهب")
                        .font(.system(size: 11))
                        .foregroundColor(Color(.navy).opacity(0.65))
                        .lineLimit(3)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Sparkle icon
                VStack(spacing: 2) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(.beige))
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(.beige))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.emarald).opacity(0.15))
        .cornerRadius(16)
    }

    // MARK: - Draft Warning

    private var draftWarningView: some View {
        Text("محفوظة كمسودة تنتهي خلال 4 ايام")
            .font(.system(size: 13, weight: .medium))
            .foregroundColor(Color(.navy))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 12)
            .background(Color(.beige).opacity(0.4))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                    .foregroundColor(Color(.beige))
            )
    }

    // MARK: - Filter / Search Row

    private var filterSearchRow: some View {
        HStack {
            // Leading in RTL (right): search
            Button(action: {
                withAnimation { showSearch.toggle(); if showSearch { showFilter = false } }
            }) {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(.navy))
                    .frame(width: 44, height: 44)
                    .background(Color(.beige))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            // Trailing in RTL (left): filter
            Button(action: {
                withAnimation { showFilter.toggle(); if showFilter { showSearch = false } }
            }) {
                Image(systemName: showFilter ? "xmark" : "slider.horizontal.3")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(showFilter ? Color("background") : Color(.navy))
                    .frame(width: 44, height: 44)
                    .background(showFilter ? Color("maincolor") : Color(.beige))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(Color(.navy).opacity(0.5))
            TextField("ابحث عن قطعة أو محل...", text: $searchText)
                .font(.system(size: 14))
                .foregroundColor(Color(.navy))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color(.beige))
        .cornerRadius(12)
    }

    // MARK: - Filter Chips

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                filterChip(label: "الكل", karat: nil)
                ForEach(Karat.allCases) { k in
                    filterChip(label: k.label, karat: k)
                }
            }
            .padding(.horizontal, 2)
        }
    }

    private func filterChip(label: String, karat: Karat?) -> some View {
        let active = filterKarat == karat
        return Button(action: { withAnimation { filterKarat = karat } }) {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(active ? Color("background") : Color(.navy))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(active ? Color("maincolor") : Color(.beige))
                .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        Text("اضغط + لاضافة قطعة ذهب للمقارنة")
            .font(.system(size: 15))
            .foregroundColor(Color(.navy).opacity(0.4))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 80)
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            tabItem(symbol: "briefcase.fill",   title: "التجوري",  active: false)
            Spacer()
            tabItem(symbol: "book.closed.fill", title: "تعلم",     active: false)
            Spacer()
            tabItem(symbol: "bookmark.fill",    title: "المقارنة", active: true)
            Spacer()
            tabItem(symbol: "house.fill",       title: "اليوم",    active: false)
        }
        .padding(.horizontal, 22)
        .padding(.top, 7)
        .padding(.bottom, 10)
        .background(
            Rectangle()
                .fill(Color("background"))
                .overlay(alignment: .top) {
                    Divider().overlay(Color(.navy).opacity(0.08))
                }
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func tabItem(symbol: String, title: String, active: Bool) -> some View {
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
                ? AnyView(RoundedRectangle(cornerRadius: 16).fill(Color(.emarald).opacity(0.15)))
                : AnyView(Color.clear)
        )
    }
}

#Preview {
    ComparisonListView()
}