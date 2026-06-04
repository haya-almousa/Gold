//
//  Tajourimodels.swift
//  Gold
//
//  Created by Raghad Alamoudi on 04/12/1447 AH.
//


import Foundation
import UIKit
import SwiftData

// MARK: - GoldKarat

enum GoldKarat: Int, CaseIterable, Identifiable, Codable {
    case k24 = 24, k21 = 21, k18 = 18
    var id: Int { rawValue }
    var label: String { "\(rawValue)k" }
}

// MARK: - GoldCondition

enum GoldCondition: String, CaseIterable, Identifiable, Codable {
    case worn   = "ملبوسة"
    case unworn = "غير ملبوسة"
    var id: String { rawValue }
}

// MARK: - GoldPieceItem

struct GoldPieceItem: Identifiable {
    let id:            UUID
    var name:          String
    var weightGrams:   Double
    var karat:         GoldKarat
    var condition:     GoldCondition
    var purchasePrice: Double
    var ownershipDate: Date?
    var imageData:     Data?

    init(
        id:            UUID          = UUID(),
        name:          String,
        weightGrams:   Double,
        karat:         GoldKarat,
        condition:     GoldCondition,
        purchasePrice: Double,
        ownershipDate: Date?         = nil,
        imageData:     Data?         = nil
    ) {
        self.id            = id
        self.name          = name
        self.weightGrams   = weightGrams
        self.karat         = karat
        self.condition     = condition
        self.purchasePrice = purchasePrice
        self.ownershipDate = ownershipDate
        self.imageData     = imageData
    }
}

// MARK: - SwiftData Model

@Model
final class PersistedTajouriPiece {
    @Attribute(.unique) var pieceID: UUID
    var name:          String
    var weightGrams:   Double
    var karatRaw:      Int
    var conditionRaw:  String
    var purchasePrice: Double
    var ownershipDate: Date?
    @Attribute(.externalStorage) var imageData: Data?

    init(from piece: GoldPieceItem) {
        self.pieceID       = piece.id
        self.name          = piece.name
        self.weightGrams   = piece.weightGrams
        self.karatRaw      = piece.karat.rawValue
        self.conditionRaw  = piece.condition.rawValue
        self.purchasePrice = piece.purchasePrice
        self.ownershipDate = piece.ownershipDate
        self.imageData     = piece.imageData
    }

    func update(from piece: GoldPieceItem) {
        self.name          = piece.name
        self.weightGrams   = piece.weightGrams
        self.karatRaw      = piece.karat.rawValue
        self.conditionRaw  = piece.condition.rawValue
        self.purchasePrice = piece.purchasePrice
        self.ownershipDate = piece.ownershipDate
        self.imageData     = piece.imageData
    }

    func toDomain() -> GoldPieceItem? {
        guard
            let karat     = GoldKarat(rawValue: karatRaw),
            let condition = GoldCondition(rawValue: conditionRaw)
        else { return nil }

        return GoldPieceItem(
            id:            pieceID,
            name:          name,
            weightGrams:   weightGrams,
            karat:         karat,
            condition:     condition,
            purchasePrice: purchasePrice,
            ownershipDate: ownershipDate,
            imageData:     imageData
        )
    }
}
