//
//  GoldItemCardView.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI

struct GoldItemCardView: View {
    let piece:    GoldPiece
    let isBest:   Bool
    let onEdit:   () -> Void
    let onDelete: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteAlert = false
    private let deleteThreshold: CGFloat = 80

    var body: some View {
        ZStack(alignment: .leading) {
            // Delete background revealed on swipe
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
                contentArea
                cameraBox
            }
            .background(Color("Lightest gold"))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isBest ? Color("Navy") : Color("Dark gold"),
                        lineWidth: 0.3
                    )
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
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                            showDeleteAlert = true
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
        }
        .clipped()
        .alert("\tحذف القطعة",isPresented: $showDeleteAlert) {
            Button("حذف", role: .destructive) { onDelete() }
            Button("الغاء", role: .cancel) { }
        } message: {
            Text("\t\tهل أنت متأكد من حذف \(piece.name)؟")
        }
    }

    // MARK: - Price View

    private var priceView: some View {
        HStack(alignment: .center, spacing: 4) {
            Image("SaudiRiyalSymbol")
                .resizable()
                .scaledToFit()
                .frame(height: 16)
            Text(piece.shopTotalWithVAT.formatted(.number.precision(.fractionLength(2))))
                .font(.appSubheadline(.heavy))
                .foregroundColor(Color("maincolor"))
        }
    }

    // MARK: - Best Badge

    private var bestBadge: some View {
        Text("افضل سعرا")
            .font(.appCaption(.bold))
            .foregroundColor(Color("maincolor"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color("Light blue"))
            .cornerRadius(8)
    }

    // MARK: - Camera Box

    private var cameraBox: some View {
        ZStack {
            if let img = piece.image {
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

    // MARK: - Content Area

    private var contentArea: some View {
        VStack(alignment: .trailing, spacing: 0) {

            // Top row: badge | spacer | name
            HStack(alignment: .center, spacing: 8) {
                if isBest { bestBadge }
                Spacer()
                Text(piece.name)
                    .font(.appBody(.bold))
                    .foregroundColor(Color("Dark gold"))
            }

            // Price + details on the same row
            HStack(alignment: .center, spacing: 0) {
                priceView
                Spacer()
                if piece.shopPrice > 0 {
                    Text("\(piece.shopPrice.clean) sar - \(piece.grams.clean)g - \(piece.karat.rawValue)k")
                        .font(.appCaption())
                        .foregroundColor(Color("Grey"))
                }
            }
            .padding(.top, 6)

            // Tags row
            HStack(spacing: 6) {
                Spacer()
                if !piece.store.isEmpty { tagPill(piece.store) }
                tagPill("\(piece.karat.rawValue)K")
                tagPill("\(piece.grams.clean)g")
            }
            .padding(.top, 6)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
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

// MARK: - Empty State

struct ComparisonEmptyStateView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(Color(.beige))
                    .frame(width: 76, height: 76)
                Circle()
                    .strokeBorder(Color("maincolor"), lineWidth: 0.5)
                    .frame(width: 76, height: 76)
                Image(systemName: "bookmark.square.fill")
                    .font(.appTitle(.regular))
                    .foregroundColor(Color(.navy))
            }
            VStack(spacing: 7) {
                Text("القائمة فارغة")
                    .font(.appTitle3(.bold))
                    .foregroundColor(Color(.navy))
                Text("اضغط + لاضافة قطعة ذهب للمقارنة")
                    .font(.appFootnote())
                    .foregroundColor(Color(.navy).opacity(0.55))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 56)
    }
}

extension Double {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(format: "%.2g", self)
    }
}
