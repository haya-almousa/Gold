//
//  Tajouriview.swift
//  Gold
//
//  Created by Raghad Alamoudi on 02/12/1447 AH.
//


internal import SwiftUI
import PhotosUI

struct TajouriView: View {

    @StateObject private var vm: TajouriViewModel

    @State private var showAddForm  = false
    @State private var pieceToEdit: GoldPieceItem? = nil

    init(dashboardVM: DashboardViewModel) {
        _vm = StateObject(wrappedValue: TajouriViewModel(dashboardVM: dashboardVM))
    }

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerCard
                    contentArea
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showAddForm) {
            AddGoldPieceSheet { newPiece in
                withAnimation { vm.addPiece(newPiece) }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $pieceToEdit) { piece in
            AddGoldPieceSheet(existingPiece: piece) { updatedPiece in
                withAnimation { vm.updatePiece(updatedPiece) }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var headerCard: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(Color("Gold"))
            .ignoresSafeArea(edges: .top)
            .overlay(headerContent)
            .frame(height: 250)
    }

    private var headerContent: some View {
        VStack(spacing: 0) {
            HStack {
                ZStack {
                    Circle()
                        .fill(Color("Dark green"))
                        .frame(width: 46, height: 46)
                    Image(systemName: "person.fill")
                        .foregroundColor(Color("background"))
                        .font(.system(size: 20))
                }
                Spacer()
                Text("التجوري")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color("Dark green"))
            }
            .padding(.top, 60)

            Group {
                if vm.isLoading {
                    Text("جاري التحديث...")
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundColor(Color("Dark green").opacity(0.6))
                } else {
                    Text("SAR \(formatNumber(vm.totalPortfolioValueSAR))")
                        .font(.system(size: 44, weight: .heavy))
                        .foregroundColor(Color("Dark green"))
                        .contentTransition(.numericText())
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 14)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.totalPortfolioValueSAR)

            Text("\(vm.pieces.count) قطع ذهب - \(String(format: "%.0f", vm.totalGrams))ج")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color("Dark green"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 4)

            Spacer().frame(height: 28)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Content Area

    private var contentArea: some View {
        VStack(spacing: 16) {
            zakatCard.padding(.top, 20)
            piecesSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Zakat Card

    private var zakatCard: some View {
        VStack(alignment: .trailing, spacing: 14) {
            HStack {
                Text(vm.meetsNisab ? "بلغ النصاب" : "لم يبلغ النصاب")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(vm.meetsNisab ? Color("Gold") : Color("Grey"))
                    .clipShape(Capsule())
                Spacer()
                HStack(spacing: 8) {

                    Text("حالة الزكاة")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(Color("Dark grey"))

                    Image(systemName: "moon.fill")
                        .foregroundColor(Color("Dark green"))
                        .font(.system(size: 18))
                        .scaleEffect(x: -1, y: 1) // يعكس اتجاه القمر
                }
            }

            VStack(alignment: .trailing, spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("Lightest grey"))
                            .frame(height: 10)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color("Dark green"))
                            .frame(
                                width: geo.size.width * min(vm.zakatableGrams / GoldConstants.nisabGrams, 1.0),
                                height: 10
                            )
                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: vm.totalGrams)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text("النصاب: \(Int(GoldConstants.nisabGrams)) ج (24K)")
                        .font(.system(size: 12))
                        .foregroundColor(Color("Grey"))
                    Spacer()
                    Text("ذهبك الخاضع للزكاة: \(String(format: "%.1f", vm.zakatableGrams))ج")                        .font(.system(size: 12))
                        .foregroundColor(Color("Grey"))
                }
            }

            GeometryReader { geo in
                Path { path in
                    path.move(to: .init(x: 0, y: 0))
                    path.addLine(to: .init(x: geo.size.width, y: 0))
                }
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundColor(Color("Light grey"))
            }
            .frame(height: 1)

            VStack(alignment: .center, spacing: 4) {
                Text("الزكاة السنوية المستحقة:")
                    .font(.system(size: 13))
                    .foregroundColor(Color("Dark grey"))
                if vm.meetsNisab {
                    Text("SAR \(formatNumber(vm.zakatDueSAR))")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color("Dark green"))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.zakatDueSAR)
                } else {
                    Text("لا توجد زكاة مستحقة")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color("Grey"))
                }
                Text("2.5% من قيمة ذهبك بسعر اليوم")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Grey"))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(Color("Lightest blue"))
        .cornerRadius(16)
        .environment(\.layoutDirection, .leftToRight)
    }

    // MARK: - Pieces Section

    private var piecesSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {

                Text("قطع الذهب")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color("Dark grey"))

                Spacer()

                Button { showAddForm = true } label: {
                    ZStack {
                        Circle()
                            .fill(Color("Gold"))
                            .frame(width: 44, height: 44)

                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color("background"))
                    }
                }
                .buttonStyle(.plain)
            }
            if vm.pieces.isEmpty {
                Text("أضغط + لإضافة قطع الذهب")
                    .font(.system(size: 15))
                    .foregroundColor(Color("Grey").opacity(0.6))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }

            ForEach(vm.pieces) { piece in
                TajouriPieceCard(
                    piece:    piece,
                    vm:       vm,
                    onEdit:   { pieceToEdit = piece },
                    onDelete: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.deletePiece(id: piece.id)
                        }
                    }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.97)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: vm.pieces.count)
    }

    // MARK: - Helpers

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value.rounded())) ?? "0"
    }
}

// MARK: - TajouriPieceCard

private struct TajouriPieceCard: View {

    let piece:    GoldPieceItem
    let vm:       TajouriViewModel
    let onEdit:   () -> Void
    let onDelete: () -> Void

    
    @State private var showActions = false

    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value.rounded())) ?? "0"
    }

    var body: some View {
        let currentVal = vm.currentValue(of: piece)
        let gainLoss   = vm.gainLoss(of: piece)
        let isGain     = gainLoss >= 0

        return HStack(spacing: 0) {

            // ── يسار: صورة ──
            ZStack {
                Color("Gold").opacity(0.5)
                if let data = piece.imageData, let img = UIImage(data: data) {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 26))
                        .foregroundColor(Color("Dark gold").opacity(0.85))
                }
            }
            .frame(width: 95)
            .frame(maxHeight: .infinity)
            .clipped()
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 14,
                    bottomLeadingRadius: 14,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            // ── يمين: المعلومات (ثابتة دائماً) ──
            VStack(alignment: .trailing, spacing: 5) {
                Spacer().frame(height: 24)

                Text(piece.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(Color("Dark grey"))
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("SAR \(formatNumber(currentVal))")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(Color("Dark green"))
                    .frame(maxWidth: .infinity, alignment: .trailing)

                Text("\(String(format: "%.1f", piece.weightGrams))ج - \(piece.karat.rawValue)K")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Grey"))
                    .frame(maxWidth: .infinity, alignment: .trailing)

                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: isGain ? "arrow.up" : "arrow.down")
                            .font(.system(size: 10, weight: .bold))

                        Text("\(isGain ? "+" : "")\(formatNumber(gainLoss))")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(isGain ? .green : .red)
                    Spacer()
                    Text("شراء: \(formatNumber(piece.purchasePrice)) SAR")
                        .font(.system(size: 11))
                        .foregroundColor(Color("Grey").opacity(0.8))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
        .frame(height: 130)
        .background(Color("Lightest gold"))
        .border(Color("Gold").opacity(0.3), width: 1)
        .cornerRadius(14)
        .environment(\.layoutDirection, .leftToRight)
        // ── إغلاق المنيو عند الضغط على الكارد ──
        .onTapGesture {
            if showActions {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                    showActions = false
                }
            }
        }
        // ── زر النقاط + dropdown — overlay فوق اسم القطعة مباشرة ──
        .overlay(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 2) {

                // زر النقاط العمودية
                Button {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                        showActions.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(showActions ? Color("Dark green") : Color("Grey"))
                        .frame(width: 36, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                // الـ dropdown يطلع أسفل الزر مباشرة
                if showActions {
                    actionMenu
                        .transition(
                            .scale(scale: 0.85, anchor: .topLeading)
                            .combined(with: .opacity)
                        )
                }
            }
            // 95 (عرض الصورة) + 12 (padding النص) = 107 — فوق الاسم تماماً
            .padding(.leading, 1)
            .padding(.top, 6)
            .zIndex(100)
        }
    }

    // MARK: - Action Menu (نفس أسلوب GoldItemCardView)

    private var actionMenu: some View {
        VStack(spacing: 0) {

            // تعديل
            Button {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                    showActions = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onEdit()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13))
                    Text("تعديل")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
                .foregroundColor(Color("Dark green"))
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color("Grey").opacity(0.15))
                .frame(height: 1)

            // حذف
            Button {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                    showActions = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    onDelete()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 13))
                    Text("حذف")
                        .font(.system(size: 15, weight: .semibold))
                    Spacer()
                }
                .foregroundColor(.red)
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(width: 130)
        .background(Color("background"))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.13), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color("Lightest gold"), lineWidth: 1.5)
        )
        .environment(\.layoutDirection, .rightToLeft)
    }
}

// MARK: - Preview

#Preview {
    TajouriView(dashboardVM: .preview)
}
