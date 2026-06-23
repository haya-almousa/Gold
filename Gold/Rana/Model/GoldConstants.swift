//
//  GoldConstants.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


import Foundation
import UIKit

enum GoldConstants {
    static let price24KUSD: Double = 98.42
    static let sarRate:     Double = 3.75
    static let nisabGrams:  Double = 85.0
    static let vatRate:     Double = 0.15
}

enum Karat: Int, CaseIterable, Identifiable {
    case k24 = 24, k21 = 21, k18 = 18
    var id: Int { rawValue }
    var multiplier: Double { Double(rawValue) / 24.0 }
    var label: String { "\(rawValue)k" }
}

struct GoldPiece: Identifiable, Equatable {
    let id:            UUID
    var name:          String
    var store:         String
    var grams:         Double
    var karat:         Karat
    var mfgFeePercent: Double
    var shopPrice:     Double
    var profitPerGram: Double
    var savedGoldPrice24KSAR: Double?
    var listID:        UUID?
    var image:         UIImage?

    init(id: UUID = UUID(), name: String, store: String = "",
         grams: Double, karat: Karat = .k21,
         mfgFeePercent: Double = 0.0,
         shopPrice: Double = 0.0,
         profitPerGram: Double = 0.0,
         savedGoldPrice24KSAR: Double? = nil,
         listID: UUID? = nil,
         image: UIImage? = nil) {
        self.id = id; self.name = name; self.store = store
        self.grams = grams; self.karat = karat
        self.mfgFeePercent = mfgFeePercent
        self.shopPrice = shopPrice
        self.profitPerGram = profitPerGram
        self.savedGoldPrice24KSAR = savedGoldPrice24KSAR
        self.listID = listID
        self.image = image
    }

    var shopTotalWithVAT: Double { shopPrice * (1 + GoldConstants.vatRate) }

    // Shop markup (making fee) locked in at the gold price when the piece was added.
    // Total moves with live gold, but the fee stays fixed, so different shops differ.
    func liveTotalWithVAT(price24KSAR: Double) -> Double {
        guard let saved = savedGoldPrice24KSAR, saved > 0 else { return shopTotalWithVAT }
        let goldValueAtSave  = grams * karat.multiplier * saved
        let makingFee        = shopPrice - goldValueAtSave
        let currentGoldValue = grams * karat.multiplier * price24KSAR
        let preTax           = currentGoldValue + makingFee
        return preTax * (1 + GoldConstants.vatRate)
    }

    var shopPricePerGram: Double {
        guard grams > 0 else { return 0 }
        return shopTotalWithVAT / grams
    }

    var totalValueSAR: Double {
        let goldValueSAR = grams * karat.multiplier * GoldConstants.price24KUSD * GoldConstants.sarRate
        let mfgChargeSAR = goldValueSAR * (mfgFeePercent / 100)
        let preTax       = goldValueSAR + mfgChargeSAR
        return preTax + preTax * GoldConstants.vatRate
    }

    var goldOnlyValueSAR: Double {
        grams * karat.multiplier * GoldConstants.price24KUSD * GoldConstants.sarRate
    }

    var vatAmountSAR: Double {
        let goldValueSAR = goldOnlyValueSAR
        let preTax       = goldValueSAR + goldValueSAR * (mfgFeePercent / 100)
        return preTax * GoldConstants.vatRate
    }

    var perGramSAR: Double {
        guard grams > 0 else { return 0 }
        return totalValueSAR / grams
    }

    func liveValueSAR(price24KSAR: Double) -> Double {
        let goldValueSAR = grams * karat.multiplier * price24KSAR
        let mfgChargeSAR = goldValueSAR * (mfgFeePercent / 100)
        let preTax       = goldValueSAR + mfgChargeSAR
        return preTax + preTax * GoldConstants.vatRate
    }

    static func == (lhs: GoldPiece, rhs: GoldPiece) -> Bool { lhs.id == rhs.id }
}

extension Array where Element == GoldPiece {
    var bestValue: GoldPiece? {
        guard count >= 2 else { return nil }
        let withPrice = filter { $0.shopPrice > 0 }
        if !withPrice.isEmpty {
            return withPrice.min(by: { $0.shopTotalWithVAT < $1.shopTotalWithVAT })
        }
        return min(by: { $0.totalValueSAR < $1.totalValueSAR })
    }
    var totalValueSAR: Double { reduce(0) { $0 + $1.totalValueSAR } }
    var totalGrams:    Double { reduce(0) { $0 + $1.grams } }
    var meetsNisab:    Bool   { totalGrams >= GoldConstants.nisabGrams }
}
