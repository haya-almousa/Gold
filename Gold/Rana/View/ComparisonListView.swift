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
    @State private var showFilter:    Bool    = false
    @State private var filterKarat:   Karat?  = nil
    @State private var showSignInPrompt: Bool = false
    @State private var showSignIn:       Bool = false
    @State private var showAddOptions:   Bool = false
    @State private var showCreateList:   Bool = false
    @State private var newListName:      String = ""
    @State private var showListsMenu:    Bool = false
    @State private var pieceToDelete:    GoldPiece? = nil
    @State private var pieceToSaveToTajouri: GoldPiece? = nil
    @ObservedObject private var auth = AuthenticationManager.shared

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
            let matchesList  = vm.selectedListID == nil || piece.listID == vm.selectedListID
            return matchesSearch && matchesKarat && matchesList
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {
                headerBar
                    .padding(.horizontal, 20)
                    .padding(.top, 30)
                    .padding(.bottom, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        if !vm.pieces.isEmpty || !vm.lists.isEmpty {
                            filterSearchRow

                            if showFilter {
                                filterChips
                            }
                        }

                        if filteredPieces.isEmpty && !vm.pieces.isEmpty {
                            Text("لا توجد نتائج")
                                .font(.appSubheadline())
                                .foregroundColor(Color(.navy).opacity(0.4))
                                .padding(.vertical, 40)
                                .frame(maxWidth: .infinity)
                        } else if vm.pieces.isEmpty {
                            emptyStateView
                        }

                        ForEach(filteredPieces) { piece in
                            GoldItemCardView(
                                piece:           piece,
                                isBest:          piece.id == vm.bestPiece?.id && vm.pieces.count > 1,
                                livePrice24KSAR: vm.liveGoldPrice24KSAR,
                                onEdit:          { withAnimation { vm.beginEdit(piece: piece) } },
                                onRequestDelete: { pieceToDelete = piece },
                                onRequestSaveToTajouri: { pieceToSaveToTajouri = piece }
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.97)))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.pieces)
                    .animation(.spring(response: 0.3, dampingFraction: 0.85), value: showFilter)
                }
            }

            
        }
        .onAppear { vm.refreshLivePrice() }
        .environment(\.layoutDirection, .leftToRight)
        .sheet(isPresented: $vm.showForm, onDismiss: { vm.cancelForm() }) {
            AddGoldFormView(vm: vm)
                .environment(\.layoutDirection, .rightToLeft)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .alert("تسجيل الدخول مطلوب", isPresented: $showSignInPrompt) {
            Button("تسجيل الدخول") { showSignIn = true }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("سجّل دخولك لإضافة قطع ذهب للمقارنة")
        }
        .sheet(isPresented: $showSignIn) {
            SignInView()
                .environmentObject(auth)
        }
        .overlay {
            if showCreateList {
                createListOverlay
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showCreateList)
        .overlay {
            if let piece = pieceToDelete {
                ConfirmDeleteOverlay(
                    title: "حذف القطعة",
                    message: "هل أنت متأكد من حذف \(piece.name)؟",
                    onConfirm: {
                        withAnimation { vm.deletePiece(id: piece.id) }
                        pieceToDelete = nil
                    },
                    onCancel: { pieceToDelete = nil }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: pieceToDelete?.id)
        .overlay {
            if let piece = pieceToSaveToTajouri {
                ConfirmSaveOverlay(
                    title: "حفظ في تجوريك",
                    message: "هل تريد حفظ \(piece.name) في تجوريك؟",
                    onConfirm: {
                        vm.saveToTajouri(piece)
                        pieceToSaveToTajouri = nil
                    },
                    onCancel: { pieceToSaveToTajouri = nil }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: pieceToSaveToTajouri?.id)
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(alignment: .center) {
            Button {
                if auth.userID.isEmpty {
                    showSignInPrompt = true
                } else {
                    showAddOptions = true
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(Color("Gold"))
                        .frame(width: 42, height: 42)
                    Image(systemName: "plus")
                        .font(.appTitle3(.bold))
                        .foregroundColor(Color("background"))
                }
                .overlay(RoundedRectangle(cornerRadius:25).stroke(Color(.darkGold), lineWidth: 0.2))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showAddOptions) {
                addOptionsPopover
                    .presentationCompactAdaptation(.popover)
            }

            if !vm.lists.isEmpty {
                listsMenuButton
            }

            Spacer()
            Text("قائمة المقارنة")
                .font(.appTitle2(.bold))
                .foregroundColor(Color(.black))
        }
    }

    // MARK: - Add Options Popover

    private var addOptionsPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            addOptionRow(title: "اضافة قطعة ذهب", icon: "plus.circle") {
                showAddOptions = false
                withAnimation { vm.toggleForm() }
            }

            Divider()

            addOptionRow(title: "انشاء قائمة جديدة", icon: "folder.badge.plus") {
                showAddOptions = false
                newListName = ""
                showCreateList = true
            }
        }
        .frame(minWidth: 220)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func addOptionRow(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Text(title)
                    .font(.appSubheadline(.semibold))
                    .foregroundColor(Color(.navy))
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(Color("maincolor"))
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color("background"))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Create List Overlay

    private var createListOverlay: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()
                .onTapGesture { showCreateList = false }

            VStack(spacing: 18) {
                Text("قائمة جديدة")
                    .font(.appTitle3(.bold))
                    .foregroundColor(Color("maincolor"))

                ThemedTextField("اسم القائمة", text: $newListName)

                HStack {
                    Button(action: { showCreateList = false }) {
                        Text("الغاء")
                            .font(.appSubheadline(.medium))
                            .foregroundColor(Color("background"))
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color("Light grey"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    Button(action: {
                        vm.createList(name: newListName)
                        showCreateList = false
                    }) {
                        Text("حفظ")
                            .font(.appSubheadline(.semibold))
                            .foregroundColor(Color("background"))
                            .padding(.horizontal, 28)
                            .padding(.vertical, 10)
                            .background(Color("maincolor"))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .background(Color("background"))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.darkGold), lineWidth: 0.3))
            .padding(.horizontal, 40)
            .environment(\.layoutDirection, .rightToLeft)
        }
        .transition(.opacity)
    }

    // MARK: - Filter / Search Row

    private var filterSearchRow: some View {
        HStack(spacing: 10) {
            Button(action: {
                withAnimation { showFilter.toggle() }
            }) {
                Image(systemName: showFilter ? "xmark" : "slider.horizontal.3")
                    .font(.appBody(.medium))
                    .foregroundColor(Color("background"))
                    .frame(width: 36, height: 36)
                    .background(showFilter ? Color("maincolor") : Color("Gold"))
                    .clipShape(Circle())
                    .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(.darkGold), lineWidth: 0.2))

            }
            .buttonStyle(.plain)

            searchBar
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack(spacing: 10) {
            TextField("ابحث عن قطعة أو محل...", text: $searchText)
                .font(.appSubheadline())
                .foregroundColor(Color(.navy))
                .multilineTextAlignment(.trailing)
            Image(systemName: "magnifyingglass")
                .font(.appSubheadline())
                .foregroundColor(Color(.navy).opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.lightestBlue))
        .cornerRadius(12)
        .environment(\.layoutDirection, .leftToRight)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.maincolor), lineWidth: 0.2))
    }

    // MARK: - Lists Menu

    private let listsMenuRowHeight: CGFloat = 46

    private var listsMenuButton: some View {
        Button {
            showListsMenu = true
        } label: {
            Image(systemName: "list.bullet")
                .font(.appTitle3(.bold))
                .foregroundColor(Color("background"))
                .frame(width: 42, height: 42)
                .background(vm.selectedListID != nil ? Color("maincolor") : Color("Gold"))
                .clipShape(Circle())
                .overlay(RoundedRectangle(cornerRadius: 25).stroke(Color(.darkGold), lineWidth: 0.2))
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showListsMenu) {
            listsMenuPopover
                .presentationCompactAdaptation(.popover)
        }
    }

    private var listsMenuPopover: some View {
        VStack(alignment: .leading, spacing: 0) {
            listsMenuRow(title: "الكل", isSelected: vm.selectedListID == nil) {
                withAnimation { vm.selectedListID = nil }
                showListsMenu = false
            }

            Divider()

            ScrollView(showsIndicators: vm.lists.count > 3) {
                VStack(spacing: 0) {
                    ForEach(vm.lists) { list in
                        listMenuListRow(list)
                        if list.id != vm.lists.last?.id {
                            Divider()
                        }
                    }
                }
            }
            .frame(maxHeight: listsMenuRowHeight * 3.5)
        }
        .frame(minWidth: 200)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func listsMenuRow(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.appSubheadline(.semibold))
                    .foregroundColor(isSelected ? Color("background") : Color(.navy))
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: listsMenuRowHeight)
            .background(isSelected ? Color("maincolor") : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func listMenuListRow(_ list: GoldList) -> some View {
        let active = vm.selectedListID == list.id
        return HStack {
            Button {
                withAnimation { vm.toggleListFilter(list.id) }
                showListsMenu = false
            } label: {
                HStack {
                    Text(list.name)
                        .font(.appSubheadline(.semibold))
                        .foregroundColor(active ? Color("background") : Color(.navy))
                    Spacer()
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                withAnimation { vm.deleteList(id: list.id) }
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(active ? Color("background") : .red)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: listsMenuRowHeight)
        .background(active ? Color("maincolor") : Color.clear)
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
                .font(.appFootnote(.semibold))
                .foregroundColor(active ? Color("background") : Color(.navy))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(active ? Color("maincolor") : Color("Lightest blue"))
                .cornerRadius(20)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color(.maincolor), lineWidth: 0.2))

        }
        .buttonStyle(.plain)
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        Text("اضغط + لاضافة قطعة ذهب للمقارنة")
            .font(.appSubheadline())
            .foregroundColor(Color(.navy).opacity(0.4))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 80)
    }

}

#Preview {
    ComparisonListView()
}

