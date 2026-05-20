//
//  Tajourimodels.swift
//  Gold
//
//  Created by Raghad Alamoudi on 04/12/1447 AH.
//


import Foundation
import UIKit
import CloudKit

// MARK: - GoldKarat

enum GoldKarat: Int, CaseIterable, Identifiable {
    case k24 = 24, k21 = 21, k18 = 18
    var id: Int { rawValue }
    var label: String { "\(rawValue)k" }
}

// MARK: - GoldCondition

enum GoldCondition: String, CaseIterable, Identifiable {
    case worn   = "مبلوسة"
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

// MARK: - UserDefaults Storage (نفس أسلوب ComparisonStorage)

enum TajouriLocalStorage {
    static let piecesKey = "tajouriView.pieces.v1"

    // Codable wrapper — نفس StoredGoldPiece في ComparisonList
    private struct Stored: Codable {
        let id:            UUID
        let name:          String
        let weightGrams:   Double
        let karatRaw:      Int
        let conditionRaw:  String
        let purchasePrice: Double
        let ownershipDate: Date?
        let imageData:     Data?
    }

    static func save(_ pieces: [GoldPieceItem], defaults: UserDefaults = .standard) {
        let stored = pieces.map {
            Stored(
                id:            $0.id,
                name:          $0.name,
                weightGrams:   $0.weightGrams,
                karatRaw:      $0.karat.rawValue,
                conditionRaw:  $0.condition.rawValue,
                purchasePrice: $0.purchasePrice,
                ownershipDate: $0.ownershipDate,
                imageData:     $0.imageData
            )
        }
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: piecesKey)
        }
    }

    static func load(defaults: UserDefaults = .standard) -> [GoldPieceItem] {
        guard
            let data   = defaults.data(forKey: piecesKey),
            let stored = try? JSONDecoder().decode([Stored].self, from: data)
        else { return [] }

        return stored.compactMap { s in
            guard
                let karat     = GoldKarat(rawValue: s.karatRaw),
                let condition = GoldCondition(rawValue: s.conditionRaw)
            else { return nil }
            return GoldPieceItem(
                id:            s.id,
                name:          s.name,
                weightGrams:   s.weightGrams,
                karat:         karat,
                condition:     condition,
                purchasePrice: s.purchasePrice,
                ownershipDate: s.ownershipDate,
                imageData:     s.imageData
            )
        }
    }
}

// MARK: - CloudKit Record Mapping (نفس أسلوب GoldPieceRecord في ComparisonList)

enum TajouriCloudRecord {
    static let recordType = "TajouriPiece"

    static func toRecord(_ piece: GoldPieceItem) -> CKRecord {
        let recordID = CKRecord.ID(recordName: piece.id.uuidString)
        let record   = CKRecord(recordType: recordType, recordID: recordID)
        record["name"]          = piece.name
        record["weightGrams"]   = piece.weightGrams
        record["karatRaw"]      = piece.karat.rawValue
        record["conditionRaw"]  = piece.condition.rawValue
        record["purchasePrice"] = piece.purchasePrice
        record["ownershipDate"] = piece.ownershipDate

        // الصورة كـ CKAsset — نفس الأسلوب في ComparisonList
        if let imageData = piece.imageData {
            let url = FileManager.default.temporaryDirectory
                        .appendingPathComponent("\(piece.id.uuidString).jpg")
            try? imageData.write(to: url)
            record["imageAsset"] = CKAsset(fileURL: url)
        }
        return record
    }

    static func fromRecord(_ record: CKRecord) -> GoldPieceItem? {
        guard
            let name     = record["name"]        as? String,
            let grams    = record["weightGrams"]  as? Double,
            let karatRaw = record["karatRaw"]     as? Int,
            let karat    = GoldKarat(rawValue: karatRaw),
            let condRaw  = record["conditionRaw"] as? String,
            let condition = GoldCondition(rawValue: condRaw),
            let id       = UUID(uuidString: record.recordID.recordName)
        else { return nil }

        let purchasePrice = record["purchasePrice"] as? Double ?? 0.0
        let ownershipDate = record["ownershipDate"] as? Date

        // استخراج الصورة من CKAsset
        var imageData: Data?
        if let asset = record["imageAsset"] as? CKAsset,
           let url   = asset.fileURL {
            imageData = try? Data(contentsOf: url)
        }

        return GoldPieceItem(
            id:            id,
            name:          name,
            weightGrams:   grams,
            karat:         karat,
            condition:     condition,
            purchasePrice: purchasePrice,
            ownershipDate: ownershipDate,
            imageData:     imageData
        )
    }
}
