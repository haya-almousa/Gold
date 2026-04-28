//
//  TojoryView.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

internal import SwiftUI



struct TojoryView: View {
    @StateObject private var vm = TojoryViewModel()
    @Environment(\.theme) private var G

    var body: some View {
        ZStack(alignment: .top) {
            Color(.navy).ignoresSafeArea()
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 24).padding(.top, 52).padding(.bottom, 18)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        if vm.showForm {
                            AddGoldFormView(vm: vm)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        if vm.pieces.isEmpty && !vm.showForm {
                            TojoryEmptyStateView().transition(.opacity)
                        }
                        if vm.pieces.count > 1, let best = vm.bestPiece {
                            BestValueBannerView(piece: best).transition(.opacity)
                        }
                        ForEach(vm.pieces) { piece in
                            GoldItemCardView(
                                piece:    piece,
                                isBest:   piece.id == vm.bestPiece?.id && vm.pieces.count > 1,
                                onEdit:   { withAnimation { vm.beginEdit(piece: piece) } },
                                onDelete: { vm.deletePiece(id: piece.id) }
                            )
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                        }
                    }
                    .padding(.horizontal, 24).padding(.bottom, 100)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.pieces)
                    .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.showForm)
                }
            }
        }
    }

    private var header: some View {
        
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Wishlist")
                    .font(.custom("Georgia", size: 28).weight(.bold)).foregroundColor(Color(.beige))
                Text("Compare gold pieces")
                    .font(.custom("Georgia", size: 13).weight(.semibold)).foregroundColor(Color(.emarald))
            }
            Spacer()
            Button(action: { withAnimation { vm.toggleForm() } }) {
                Image(systemName: vm.showForm ? "xmark" : "plus")
                    .font(.system(size: 18, weight: .semibold)).foregroundColor(G.bg)
                    .frame(width: 42, height: 42)
                    .background(LinearGradient(
                        colors: [G.goldDark, G.gold],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .cornerRadius(13)
            }
        }
       
    }
}

// MARK: - Preview

#Preview {
    TojoryView()
        .environment(\.theme, AppTheme.light)
}

