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

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // topTrailing in RTL = top-LEFT visually (badge position)

            HStack(spacing: 0) {
                // FIRST in RTL HStack = RIGHT side: camera box
                cameraBox

                // SECOND in RTL HStack = LEFT side: content
                contentArea
            }
            .background(Color(.beige))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isBest ? Color(.emarald) : Color(.beige).opacity(0.5),
                        lineWidth: 1.5
                    )
            )

            // "أفضل سعر!" badge — top-LEFT of card in RTL
            if isBest {
                Text("أفضل سعر!")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color("background"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.emarald))
                    .cornerRadius(8)
                    .padding(.top, 10)
                    .padding(.trailing, 10)
            }
        }
        .contextMenu {
            Button(role: .destructive, action: onDelete) {
                Label("حذف", systemImage: "trash")
            }
            Button(action: onEdit) {
                Label("تعديل", systemImage: "pencil")
            }
        }
    }

    // MARK: - Camera Box (right side in RTL)

    private var cameraBox: some View {
        ZStack {
            if let img = piece.image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Color(.beige).opacity(0.6)
                Image(systemName: "camera")
                    .font(.system(size: 24))
                    .foregroundColor(Color(.navy).opacity(0.4))
            }
        }
        .frame(width: 90)
        .frame(maxHeight: .infinity)
        .background(Color(.beige).opacity(0.6))
        .onTapGesture { onEdit() }
    }

    // MARK: - Content Area (left side in RTL)

    private var contentArea: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Name — right-aligned (trailing in RTL = right side)
            Text(piece.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color(.navy))
                .frame(maxWidth: .infinity, alignment: .trailing)

            // SAR Price — teal, large
            Text("SAR \(piece.shopTotalWithVAT.formatted(.number.precision(.fractionLength(2))))")
                .font(.system(size: 20, weight: .heavy))
                .foregroundColor(Color("maincolor"))
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.top, 2)

            // Summary line with dash separators
            if piece.shopPrice > 0 {
                Text("\(piece.shopPrice.clean) sar - \(piece.grams.clean)g - \(piece.karat.rawValue)k")
                    .font(.system(size: 12))
                    .foregroundColor(Color(.navy).opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
            }

            // Pill tags
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
            .foregroundColor(Color(.navy))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(.beige).opacity(0.7))
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
                    .strokeBorder(Color(.emarald), lineWidth: 0.5)
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