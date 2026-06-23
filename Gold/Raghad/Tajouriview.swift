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
    @State private var pieceToDelete: GoldPieceItem? = nil
    @State private var showPaywall = false

    @ScaledMetric(relativeTo: .largeTitle) private var portfolioFontSize: CGFloat = 44
    @ScaledMetric(relativeTo: .title)      private var zakatFontSize: CGFloat = 34
    @State private var showProfile = false
    @State private var showEducation = false
    @State private var showSignInPrompt = false
    @ObservedObject private var subscription = SubscriptionManager.shared
    @EnvironmentObject var auth: AuthenticationManager

    init(dashboardVM: DashboardViewModel) {
        _vm = StateObject(wrappedValue: TajouriViewModel(dashboardVM: dashboardVM))
    }

    var body: some View {
        ZStack {
            Color("background").ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: - ثابت مثل صفحة المقارنة
                headerCard

                // MARK: - المحتوى المتحرك فقط
                ScrollView(showsIndicators: false) {
                    contentArea
                        .padding(.top, 20)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
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
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .sheet(isPresented: $showEducation) {
            EducationView()
        }
        .alert("تسجيل الدخول مطلوب", isPresented: $showSignInPrompt) {
            Button("تسجيل الدخول") { showProfile = true }
            Button("إلغاء", role: .cancel) {}
        } message: {
            Text("سجّل دخولك لحفظ قطع الذهب في تجوريك")
        }
        .overlay {
            if let piece = pieceToDelete {
                ConfirmDeleteOverlay(
                    title: "حذف القطعة",
                    message: "هل أنت متأكد من حذف \(piece.name)؟",
                    onConfirm: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            vm.deletePiece(id: piece.id)
                        }
                        pieceToDelete = nil
                    },
                    onCancel: { pieceToDelete = nil }
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: pieceToDelete?.id)
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
                VStack(spacing: 8) {
                    Button { showProfile = true } label: {
                        ZStack {
                            Circle()
                                .fill(Color("Dark green"))
                                .frame(width: 46, height: 46)
                            Image(systemName: "person.fill")
                                .foregroundColor(Color("background"))
                                .font(.appTitle3())
                        }
                    }
                    .buttonStyle(.plain)

                    Button { showEducation = true } label: {
                        ZStack {
                            Circle()
                                .fill(Color("Dark green"))
                                .frame(width: 40, height: 40)
                            Image(systemName: "book.closed.fill")
                                .foregroundColor(Color("background"))
                                .font(.appSubheadline(.bold))
                        }
                    }
                    .buttonStyle(.plain)
                }

                Spacer()
                Text("التجوري")
                    .font(.appTitle2(.bold))
                    .foregroundColor(Color("Dark green"))
            }
            .padding(.top, 60)

            Group {
                if vm.isLoading {
                    Text("جاري التحديث...")
                        .font(.appTitle(.heavy))
                        .foregroundColor(Color("Dark green").opacity(0.6))
                } else {
                    Text("SAR \(formatNumber(vm.totalPortfolioValueSAR))")
                        .font(.system(size: portfolioFontSize, weight: .heavy))
                        .foregroundColor(Color("Dark green"))
                        .contentTransition(.numericText())
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.top, 14)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.totalPortfolioValueSAR)

            Text("\(vm.pieces.count) قطع ذهب - \(String(format: "%.0f", vm.totalGrams))ج")
                .font(.appBody(.medium))
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
            if !subscription.isPremium {
                premiumBannerView
            }
            zakatCard.padding(.top, 20)
            piecesSection
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 100)
        .environment(\.layoutDirection, .rightToLeft)
    }

    // MARK: - Premium Banner

    private var premiumBannerView: some View {
        HStack(spacing: 12) {
            HStack(alignment: .top, spacing: 6) {
                VStack(spacing: 9) {
                    Image(systemName: "sparkle")
                        .font(.appTitle2(.bold))
                        .foregroundColor(Color("Dark gold"))
                    Image(systemName: "sparkle")
                        .font(.appSubheadline(.bold))
                        .foregroundColor(Color("Dark gold"))
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("فتح التجوري بالكامل")
                        .font(.appSubheadline(.bold))
                        .foregroundColor(Color("Dark green"))
                    Text("جرّب كل المميزات لمدة 7 أيام مجانًا\nثم 19.99 ر.س شهريًا فقط")
                        .font(.appCaption())
                        .foregroundColor(Color("Dark green"))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button(action: { showPaywall = true }) {
                Text("جرب مجانا")
                    .font(.appFootnote(.semibold))
                    .foregroundColor(Color("Dark green"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color("Lightest gold"))
                    .cornerRadius(22)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color("Dark green").opacity(0.2), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color("Lightest gold"))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color("Dark gold").opacity(0.3), lineWidth: 0.2))
        .onTapGesture { showPaywall = true }
    }

    // MARK: - Zakat Card

    private var zakatCard: some View {
        VStack(alignment: .trailing, spacing: 14) {
            HStack {
                Text(vm.meetsNisab ? "بلغ النصاب" : "لم يبلغ النصاب")
                    .font(.appFootnote(.bold))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(vm.meetsNisab ? Color("Nisab") : Color(.grey.opacity(0.55)))
                    .clipShape(Capsule())
                Spacer()
                HStack(spacing: 8) {

                    Text("حالة الزكاة")
                        .font(.appTitle3(.bold))
                        .foregroundColor(Color("Dark green"))

                    Image(systemName: "moon.fill")
                        .foregroundColor(Color("Dark green"))
                        .font(.appTitle3(.bold))
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
                        .font(.appCaption(.medium))
                        .foregroundColor(Color("Grey"))
                    Spacer()
                    Text("ذهبك الخاضع للزكاة: \(String(format: "%.1f", vm.zakatableGrams))ج")                        .font(.appCaption(.medium))
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
                    .font(.appCaption(.medium, ))
                    .foregroundColor(Color("Dark grey"))
                if vm.meetsNisab {
                    Text("SAR \(formatNumber(vm.zakatDueSAR))")
                        .font(.system(size: zakatFontSize, weight: .bold))
                        .foregroundColor(Color("Dark green"))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: vm.zakatDueSAR)
                } else {
                    Text("لا توجد زكاة مستحقة")
                        .font(.appTitle3(.bold))
                        .foregroundColor(Color("Dark green"))
                }
                Text("2.5% من قيمة ذهبك بسعر اليوم")
                    .font(.appCaption(.medium))
                    .foregroundColor(Color("Dark grey"))
            }
            .frame(maxWidth: .infinity)
        }
        .padding(18)
        .background(Color("Lightest blue"))
        .cornerRadius(16)
        .environment(\.layoutDirection, .leftToRight)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color(.maincolor), lineWidth: 0.1))

    }

    // MARK: - Pieces Section

    private var piecesSection: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {

                Text("قطع الذهب")
                    .font(.appTitle3(.bold))
                    .foregroundColor(Color(.black))

                Spacer()

                Button {
                    if auth.userID.isEmpty {
                        showSignInPrompt = true
                    } else {
                        showAddForm = true
                    }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color("Gold"))
                            .frame(width: 36, height: 36)

                        Image(systemName: "plus")
                            .font(.appBody(.bold))
                            .foregroundColor(Color("background"))
                    }
                    .overlay(RoundedRectangle(cornerRadius:25).stroke(Color(.darkGold), lineWidth: 0.2))

                }
                .buttonStyle(.plain)
            }
            if vm.pieces.isEmpty {
                Text("أضغط + لإضافة قطع الذهب")
                    .font(.appBody())
                    .foregroundColor(Color("Grey").opacity(0.6))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
            }

            ForEach(vm.pieces) { piece in
                TajouriPieceCard(
                    piece:           piece,
                    vm:              vm,
                    onEdit:          { pieceToEdit = piece },
                    onRequestDelete: { pieceToDelete = piece }
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

    let piece:           GoldPieceItem
    let vm:              TajouriViewModel
    let onEdit:          () -> Void
    let onRequestDelete: () -> Void

    @State private var dragOffset: CGFloat = 0
    private let deleteThreshold: CGFloat = 80

    private func fmt(_ value: Double) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        f.locale = Locale(identifier: "en_US")
        return f.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    var body: some View {
        let currentVal = vm.currentValue(of: piece)
        let gainLoss   = vm.gainLoss(of: piece)
        let isGain     = gainLoss >= 0

        ZStack(alignment: .leading) {
            // Delete background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("Light red"))
                .overlay(
                    Image(systemName: "trash")
                        .font(.appTitle3(.bold))
                        .foregroundColor(Color("Red"))
                        .padding(.leading, 24),
                    alignment: .leading
                )

            // Card content
            HStack(spacing: 0) {
                // Info area
                VStack(alignment: .trailing, spacing: 0) {
                    HStack(alignment: .center, spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            HStack(spacing: 3) {
                                Image(systemName: isGain ? "arrow.up" : "arrow.down")
                                    .font(.appCaption(.bold))
                                Text("\(isGain ? "+" : "")\(fmt(gainLoss))")
                                    .font(.appCaption(.semibold))
                            }
                            .foregroundColor(isGain ? .green : .red)
                        }
                        Spacer()
                        Text(piece.name)
                            .font(.appBody(.bold))
                            .foregroundColor(Color("Dark gold"))
                            .lineLimit(1)
                    }

                    HStack(alignment: .center, spacing: 0) {
                        HStack(spacing: 4) {
                            Image("SaudiRiyalSymbol")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 16)
                            Text(fmt(currentVal))
                                .font(.appSubheadline(.heavy))
                                .foregroundColor(Color("maincolor"))
                        }
                        Spacer()
                        Text("شراء: \(fmt(piece.purchasePrice)) ر.س")
                            .font(.appCaption())
                            .foregroundColor(Color("Grey"))
                    }
                    .padding(.top, 6)

                    HStack(spacing: 6) {
                        Spacer()
                        tagPill("\(piece.karat.rawValue)K")
                        tagPill("\(piece.weightGrams.clean)g")
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 14)
                .frame(maxWidth: .infinity)

                // Image box
                ZStack {
                    if let data = piece.imageData, let img = UIImage(data: data) {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                    } else {
                        Color("Gold")
                        Image(systemName: "camera.fill")
                            .font(.appTitle2())
                            .foregroundColor(Color("Dark gold"))
                    }
                }
                .frame(width: 90)
                .frame(maxHeight: .infinity)
                .background(Color("Gold"))
                .clipped()
            }
            .background(Color("Lightest gold"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color("Dark gold"), lineWidth: 0.3)
            )
            .offset(x: dragOffset)
            .onTapGesture { onEdit() }
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .local)
                    .onChanged { value in
                        guard abs(value.translation.width) > abs(value.translation.height),
                              value.translation.width > 0 else { return }
                        dragOffset = min(value.translation.width, 120)
                    }
                    .onEnded { _ in
                        if dragOffset > deleteThreshold {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { dragOffset = 0 }
                            onRequestDelete()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { dragOffset = 0 }
                        }
                    }
            )
        }
        .clipped()
        .environment(\.layoutDirection, .leftToRight)
    }

    private func tagPill(_ text: String) -> some View {
        Text(text)
            .font(.appCaption(.medium))
            .foregroundColor(Color("maincolor"))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color("Lightest blue"))
            .cornerRadius(6)
    }
}

// MARK: - Preview

#Preview {
    TajouriView(dashboardVM: .preview)
}
