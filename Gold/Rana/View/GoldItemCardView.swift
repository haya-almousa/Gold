//
//  GoldItemCardView.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


internal import SwiftUI

struct GoldItemCardView: View {
    let piece:           GoldPiece
    let isBest:          Bool
    let livePrice24KSAR: Double?
    let previousPrice24KSAR: Double?
    let onEdit:          () -> Void
    let onDelete:        () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var showDeleteAlert = false
    private let deleteThreshold: CGFloat = 80

    var body: some View {
        ZStack(alignment: .leading) {
            // Delete background revealed on swipe
            RoundedRectangle(cornerRadius: 20)
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
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
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

    private var displayedPrice: Double {
        if let live = livePrice24KSAR {
            return piece.liveTotalWithVAT(price24KSAR: live)
        }
        return piece.shopTotalWithVAT
    }

    private var priceDiff: Double? {
        guard let live = livePrice24KSAR, let prev = previousPrice24KSAR else { return nil }
        return piece.liveTotalWithVAT(price24KSAR: live) - piece.liveTotalWithVAT(price24KSAR: prev)
    }

    private var priceView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 4) {
                Image("SaudiRiyalSymbol")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 16)
                Text(displayedPrice.formatted(.number.precision(.fractionLength(2))))
                    .font(.appSubheadline(.heavy))
                    .foregroundColor(Color("maincolor"))
            }

            if let diff = priceDiff, abs(diff) >= 0.01 {
                let isUp = diff > 0
                HStack(spacing: 3) {
                    Image(systemName: isUp ? "arrow.up" : "arrow.down")
                        .font(.appCaption(.bold))
                    Text("\(isUp ? "+" : "")\(diff.formatted(.number.precision(.fractionLength(2))))")
                        .font(.appCaption(.semibold))
                }
                .foregroundColor(isUp ? Color.red : Color.green)
            }
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
                    Text("\(piece.shopPrice.clean) SAR")
                        .font(.appCaption())
                        .foregroundColor(Color("Grey"))
                }
            }
            .padding(.top, 2)

            // Tags row
            HStack(spacing: 6) {
                Spacer()
                if !piece.store.isEmpty { tagPill(piece.store) }
                tagPill("\(piece.karat.rawValue)K")
                tagPill("\(piece.grams.clean)g")
            }
            .padding(.top, 2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
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
        if truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", self)
        }
        var s = String(format: "%.2f", self)
        while s.hasSuffix("0") { s = String(s.dropLast()) }
        if s.hasSuffix(".") { s = String(s.dropLast()) }
        return s
    }
}
