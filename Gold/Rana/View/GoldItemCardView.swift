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

    @State private var showActions = false

    var body: some View {
        HStack(spacing: 0) {
            cameraBox
            contentArea
        }
        .background(Color("Lightest gold"))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isBest ? Color("maincolor") : Color("Gold"),
                    lineWidth: 0.3
                )
        )
        .overlay(alignment: .topLeading) {
            if isBest { bestBadge }
        }
        .overlay(alignment: .topTrailing) {
            VStack(alignment: .trailing, spacing: 2) {
                Button(action: {
                    withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                        showActions.toggle()
                    }
                }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(.navy).opacity(0.45))
                        .rotationEffect(.degrees(90))
                        .frame(width: 36, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if showActions {
                    actionMenu
                        .transition(
                            .scale(scale: 0.85, anchor: .topTrailing)
                            .combined(with: .opacity)
                        )
                }
            }
            .padding(.top, 6)
            .padding(.trailing, 6)
            .zIndex(1)
        }
        .onTapGesture {
            if showActions {
                withAnimation(.spring(response: 0.22, dampingFraction: 0.75)) {
                    showActions = false
                }
            }
        }
    }

    // MARK: - Themed Action Menu

    private var actionMenu: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation { showActions = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onEdit() }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .medium))
                    Text("تعديل")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .foregroundColor(Color("maincolor"))
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
            }
            .buttonStyle(.plain)

            Rectangle()
                .fill(Color(.navy).opacity(0.08))
                .frame(height: 1)

            Button(action: {
                withAnimation { showActions = false }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { onDelete() }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 13, weight: .medium))
                    Text("حذف")
                        .font(.system(size: 14, weight: .medium))
                    Spacer()
                }
                .foregroundColor(Color("Red"))
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 118)
        .background(Color("background"))
        .cornerRadius(12)
        .shadow(color: Color(.navy).opacity(0.13), radius: 12, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.navy).opacity(0.07), lineWidth: 1)
        )
    }

    // MARK: - Best Badge

    private var bestBadge: some View {
        Text("افضل سعرا")
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(Color("maincolor"))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color("Light blue"))
            .cornerRadius(8)
            .padding(.top, 10)
            .padding(.leading, 10)
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
                    .font(.system(size: 24))
                    .foregroundColor(Color("Dark gold"))
            }
        }
        .frame(width: 90)
        .frame(maxHeight: .infinity)
        .background(Color("Gold"))
        .onTapGesture {
            if showActions {
                withAnimation { showActions = false }
            } else {
                onEdit()
            }
        }
    }

    // MARK: - Content Area

    private var contentArea: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(piece.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color("Dark gold"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 28)

            Text("SAR \(piece.shopTotalWithVAT.formatted(.number.precision(.fractionLength(2))))")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(Color("maincolor"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 2)

            if piece.shopPrice > 0 {
                Text("\(piece.shopPrice.clean) sar - \(piece.grams.clean)g - \(piece.karat.rawValue)k")
                    .font(.system(size: 12))
                    .foregroundColor(Color("Grey"))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
            }

            HStack(spacing: 6) {
                Spacer()
                if !piece.store.isEmpty {
                    tagPill(piece.store)
                }
                tagPill("\(piece.karat.rawValue)K")
                tagPill("\(piece.grams.clean)g")
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
    }

    private func tagPill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .medium))
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
                    .font(.system(size: 32))
                    .foregroundColor(Color(.navy))
            }
            VStack(spacing: 7) {
                Text("القائمة فارغة")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(.navy))
                Text("اضغط + لاضافة قطعة ذهب للمقارنة")
                    .font(.system(size: 13))
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
