//
//  GoldConstants.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

import Foundation
import UIKit


enum GoldConstants {
    static let price24KUSD: Double = 98.42
    static let sarRate:     Double = 3.75
    static let nisabGrams:  Double = 85.0
    /// Saudi VAT — constant, never user-editable
    static let vatRate:     Double = 0.15
}

enum Karat: Int, CaseIterable, Identifiable {
    case k24 = 24, k22 = 22, k21 = 21, k18 = 18
    var id: Int { rawValue }
    var multiplier: Double { Double(rawValue) / 24.0 }
    var label: String { "\(rawValue)K" }
}

struct GoldPiece: Identifiable, Equatable {
    let id:            UUID
    var name:          String
    var store:         String
    var grams:         Double
    var karat:         Karat
    var mfgFeePercent: Double
    var image:         UIImage?

    init(id: UUID = UUID(), name: String, store: String = "",
         grams: Double, karat: Karat = .k21,
         mfgFeePercent: Double = 8.0, image: UIImage? = nil) {
        self.id = id; self.name = name; self.store = store
        self.grams = grams; self.karat = karat
        self.mfgFeePercent = mfgFeePercent; self.image = image
    }

    /// Total SAR value using the official formula:
    /// (Weight × Purity Factor × Spot Price/g) + Manufacturing Charges + VAT (15%)
    var totalValueSAR: Double {
        let goldValueSAR = grams * karat.multiplier * GoldConstants.price24KUSD * GoldConstants.sarRate
        let mfgChargeSAR = goldValueSAR * (mfgFeePercent / 100)
        let preTax       = goldValueSAR + mfgChargeSAR
        return preTax + preTax * GoldConstants.vatRate
    }

    /// Gold value only (before mfg + VAT)
    var goldOnlyValueSAR: Double {
        grams * karat.multiplier * GoldConstants.price24KUSD * GoldConstants.sarRate
    }

    /// VAT amount in SAR
    var vatAmountSAR: Double {
        let goldValueSAR = goldOnlyValueSAR
        let preTax       = goldValueSAR + goldValueSAR * (mfgFeePercent / 100)
        return preTax * GoldConstants.vatRate
    }

    /// SAR per gram (total including mfg + VAT)
    var perGramSAR: Double {
        guard grams > 0 else { return 0 }
        return totalValueSAR / grams
    }

    static func == (lhs: GoldPiece, rhs: GoldPiece) -> Bool { lhs.id == rhs.id }
}

extension Array where Element == GoldPiece {
    var bestValue:    GoldPiece? { count >= 2 ? min(by: { $0.totalValueSAR < $1.totalValueSAR }) : nil }
    var totalValueSAR: Double   { reduce(0) { $0 + $1.totalValueSAR } }
    var totalGrams:    Double   { reduce(0) { $0 + $1.grams } }
    var meetsNisab:    Bool     { totalGrams >= GoldConstants.nisabGrams }
}
