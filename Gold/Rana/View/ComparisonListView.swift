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

    @Binding var selectedTab: AppTab
    
    init(selectedTab: Binding<AppTab> = .constant(.comparison)) {
        _selectedTab = selectedTab
    }
    
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

            
        }
        .environment(\.layoutDirection, .leftToRight)
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
            Button(action: { withAnimation { vm.toggleForm() } }) {
                ZStack {
                    Circle()
                        .fill(Color("Gold"))
                        .frame(width: 46, height: 46)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color("background"))
                }
            }
            Spacer()
            Text("قائمة المقارنة")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(.navy))
        }
    }

    // MARK: - Premium Banner

    private var premiumBannerView: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Text("جرب مجانا")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(.navy))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("Very Light blue"))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color(.navy).opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            HStack(alignment: .top, spacing: 6) {
                VStack(alignment: .trailing, spacing: 4) {
                    Text("فتح المقارنة بالكامل")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(.navy))
                    Text("تجربة مجانية لمدة 7 ايام - احفظ \nوقارن قطع الذهب")
                        .font(.system(size: 11))
                        .foregroundColor(Color(.navy))
                        .lineLimit(3)
                        .multilineTextAlignment(.trailing)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)

                VStack(spacing: 2) {
                    Image(systemName: "sparkle")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(Color(.yellow))
                    Image(systemName: "sparkle")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(.yellow))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color("Lightest blue"))
        .cornerRadius(16)
    }

    // MARK: - Draft Warning

    private var draftWarningView: some View {
        Text("محفوظة كمسودة تنتهي خلال 4 ايام")
            .font(.system(size: 13, weight: .bold))
            .foregroundColor(Color("Dark gold"))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 12)
            .background(Color("Lightest gold"))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
                    .foregroundColor(Color("Gold"))
            )
    }

    // MARK: - Filter / Search Row

    private var filterSearchRow: some View {
        HStack {
            Button(action: {
                withAnimation { showFilter.toggle(); if showFilter { showSearch = false } }
            }) {
                Image(systemName: showFilter ? "xmark" : "slider.horizontal.3")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("background"))
                    .frame(width: 44, height: 44)
                    .background(showFilter ? Color("maincolor") : Color("Gold"))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: {
                withAnimation { showSearch.toggle(); if showSearch { showFilter = false } }
            }) {
                Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color("background"))
                    .frame(width: 44, height: 44)
                    .background(showSearch ? Color("maincolor") : Color("Gold"))
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

}

#Preview {
    ComparisonListView()
}
