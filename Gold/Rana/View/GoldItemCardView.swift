//
//  GoldItemCardView.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

internal import SwiftUI



struct GoldItemCardView: View {
    let piece:    GoldPiece
    let isBest:   Bool
    let onEdit:   () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Thumbnail
            ZStack(alignment: .topLeading) {
                Group {
                    if let img = piece.image {
                        Image(uiImage: img).resizable().scaledToFill()
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 3).fill(Color.beige.opacity(0.55))
                                .frame(width: 46, height: 26)
                            RoundedRectangle(cornerRadius: 2).fill(Color.beige.opacity(0.4))
                                .frame(width: 36, height: 16)
                        }
                    }
                }
                .frame(width: 86, height: 86).clipped()

                if isBest {
                    Text("BEST")
                        .font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.beige).cornerRadius(5).padding(5)
                }
            }
            .frame(width: 86, height: 86).background(Color.beige)

            // Details
            VStack(alignment: .leading, spacing: 0) {
                Text(piece.name)
                    .font(.system(size: 14, weight: .semibold)).foregroundColor(Color.beige)

                if !piece.store.isEmpty {
                    Text(piece.store).font(.system(size: 11)).foregroundColor(Color.beige).padding(.top, 1)
                }

                HStack(spacing: 6) {
                    ForEach(["\(piece.grams.clean)g", "\(piece.karat.rawValue)K",
                             "\(piece.mfgFeePercent.clean)%"], id: \.self) { tag in
                        Text(tag).font(.system(size: 11)).foregroundColor(Color(.navy))
                            .padding(.horizontal, 7).padding(.vertical, 2)
                            .background(Color(.beige)).cornerRadius(5)
                    }
                }
                .padding(.top, 6)

                HStack {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("SAR \(piece.totalValueSAR.formatted(.number.precision(.fractionLength(2))))")
                            .font(.system(size: 15, weight: .bold)).foregroundColor(Color(.emarald))
                        Text("SAR \(piece.perGramSAR.formatted(.number.precision(.fractionLength(2))))/g")
                            .font(.system(size: 11)).foregroundColor(Color(.emarald))
                    }
                    Spacer()
                    HStack(spacing: 14) {
                        Button(action: onEdit) {
                            Image(systemName: "pencil")
                                .font(.system(size: 14)).foregroundColor(Color(.emarald))
                        }
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 14)).foregroundColor(Color(.emarald))
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(13).frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color(.beige)).cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(isBest ? Color(.beige) : Color(.emarald), lineWidth: 1))
    }
}

struct BestValueBannerView: View {
    let piece: GoldPiece

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(Color(.beige)).font(.system(size: 17))
            VStack(alignment: .leading, spacing: 2) {
                Text("Best Value: \(piece.name)")
                    .font(.system(size: 13, weight: .semibold)).foregroundColor(Color(.navy))
                Text("SAR \(piece.totalValueSAR.formatted(.number.precision(.fractionLength(2)))) — lowest price")
                    .font(.system(size: 12)).foregroundColor(Color(.navy))
            }
            Spacer()
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
        .background(Color(.beige)).cornerRadius(13)
        .overlay(RoundedRectangle(cornerRadius: 13).stroke(Color(.beige).opacity(0.27), lineWidth: 1))
    }
}

struct TojoryEmptyStateView: View {
    var body: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle().fill(Color(.beige).opacity(0.1)).frame(width: 76, height: 76)
                Circle().strokeBorder(Color(.emarald), lineWidth: 0.5).frame(width: 76, height: 76)
                Image(systemName: "lock.square.stack.fill")
                    .font(.system(size: 32)).foregroundColor(Color(.beige))
            }
            VStack(spacing: 7) {
                Text("Your safe is empty")
                    .font(.custom("Georgia", size: 20).weight(.bold)).foregroundColor(Color(.beige))
                Text("Tap + to add your first gold piece")
                    .font(.custom("Georgia", size: 14).weight(.semibold)).foregroundColor(Color(.emarald))
            }
        }
        .frame(maxWidth: .infinity).padding(.vertical, 56)
    }
}

extension Double {
    var clean: String {
        truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", self)
            : String(format: "%.2g", self)
    }
}
