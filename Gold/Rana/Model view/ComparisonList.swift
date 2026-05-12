//
//  ComparisonList.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


import Foundation
import Combine
import UIKit
import CloudKit
internal import SwiftUI
import PhotosUI

extension Notification.Name {
    static let tojoryPiecesDidChange = Notification.Name("tojoryPiecesDidChange")
}

// MARK: - Local Cache (UserDefaults)

private struct StoredGoldPiece: Codable {
    let id:            UUID
    let name:          String
    let store:         String
    let grams:         Double
    let karatRawValue: Int
    let mfgFeePercent: Double
    let shopPrice:     Double?
}

private enum ComparisonStorage {
    static let piecesKey = "tojory.pieces.v1"

    static func save(_ pieces: [GoldPiece], defaults: UserDefaults = .standard) {
        let stored = pieces.map {
            StoredGoldPiece(
                id:            $0.id,
                name:          $0.name,
                store:         $0.store,
                grams:         $0.grams,
                karatRawValue: $0.karat.rawValue,
                mfgFeePercent: $0.mfgFeePercent,
                shopPrice:     $0.shopPrice
            )
        }
        if let data = try? JSONEncoder().encode(stored) {
            defaults.set(data, forKey: piecesKey)
        }
    }

    static func load(defaults: UserDefaults = .standard) -> [GoldPiece] {
        guard
            let data   = defaults.data(forKey: piecesKey),
            let stored = try? JSONDecoder().decode([StoredGoldPiece].self, from: data)
        else { return [] }

        return stored.compactMap { item in
            guard let karat = Karat(rawValue: item.karatRawValue) else { return nil }
            return GoldPiece(
                id:            item.id,
                name:          item.name,
                store:         item.store,
                grams:         item.grams,
                karat:         karat,
                mfgFeePercent: item.mfgFeePercent,
                shopPrice:     item.shopPrice ?? 0.0,
                image:         nil
            )
        }
    }
}

// MARK: - CloudKit Record Mapping

private enum GoldPieceRecord {
    static let recordType = "GoldPiece"

    static func toRecord(_ piece: GoldPiece) -> CKRecord {
        let recordID = CKRecord.ID(recordName: piece.id.uuidString)
        let record   = CKRecord(recordType: recordType, recordID: recordID)
        record["name"]          = piece.name
        record["store"]         = piece.store
        record["grams"]         = piece.grams
        record["karatRawValue"] = piece.karat.rawValue
        record["mfgFeePercent"] = piece.mfgFeePercent
        record["shopPrice"]     = piece.shopPrice

        if let image = piece.image,
           let data  = image.jpegData(compressionQuality: 0.7) {
            let url = FileManager.default.temporaryDirectory
                        .appendingPathComponent("\(piece.id.uuidString).jpg")
            try? data.write(to: url)
            record["imageAsset"] = CKAsset(fileURL: url)
        }
        return record
    }

    static func fromRecord(_ record: CKRecord) -> GoldPiece? {
        guard
            let name     = record["name"]          as? String,
            let grams    = record["grams"]         as? Double,
            let karatRaw = record["karatRawValue"] as? Int,
            let karat    = Karat(rawValue: karatRaw),
            let id       = UUID(uuidString: record.recordID.recordName)
        else { return nil }

        let store         = record["store"]         as? String ?? ""
        let mfgFeePercent = record["mfgFeePercent"] as? Double ?? 0.0
        let shopPrice     = record["shopPrice"]     as? Double ?? 0.0

        var image: UIImage?
        if let asset = record["imageAsset"] as? CKAsset,
           let url   = asset.fileURL,
           let data  = try? Data(contentsOf: url) {
            image = UIImage(data: data)
        }

        return GoldPiece(
            id:            id,
            name:          name,
            store:         store,
            grams:         grams,
            karat:         karat,
            mfgFeePercent: mfgFeePercent,
            shopPrice:     shopPrice,
            image:         image
        )
    }
}

// MARK: - ViewModel

@MainActor
final class ComparisonListViewModel: ObservableObject {

    @Published private(set) var pieces:        [GoldPiece]      = []
    @Published var            showForm:         Bool              = false
    @Published var            form:             AddGoldFormState  = .empty()
    @Published var            selectedImage:    UIImage?          = nil
    @Published var            pickerItem:       PhotosPickerItem? = nil
    @Published private(set) var formError:      String?           = nil
    @Published private(set) var editingID:      UUID?             = nil
    @Published private(set) var isSyncing:      Bool              = false

    var isEditing: Bool { editingID != nil }

    private let db = CKContainer(identifier: "iCloud.HayaAlmousa.Gold")
                        .privateCloudDatabase

    init() {
        pieces = ComparisonStorage.load()   // show cached data instantly
        Task { await loadFromCloudKit() }   // then sync from CloudKit
    }

    var bestPiece:     GoldPiece? { pieces.bestValue }
    var totalValueSAR: Double     { pieces.totalValueSAR }
    var totalGrams:    Double     { pieces.totalGrams }
    var meetsNisab:    Bool       { pieces.meetsNisab }

    func toggleForm() {
        if showForm { resetForm() }
        showForm.toggle()
    }

    func cancelForm() { resetForm(); showForm = false }

    func updateField<T>(_ keyPath: WritableKeyPath<AddGoldFormState, T>, value: T) {
        form[keyPath: keyPath] = value
        formError = nil
    }

    func loadSelectedImage() async {
        guard let item = pickerItem,
              let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        selectedImage = image
    }

    func beginEdit(piece: GoldPiece) {
        editingID     = piece.id
        selectedImage = piece.image
        form = AddGoldFormState(
            name:          piece.name,
            store:         piece.store,
            gramsText:     piece.grams.clean,
            karat:         piece.karat,
            shopPriceText: piece.shopPrice > 0 ? piece.shopPrice.clean : ""
        )
        showForm = true
    }

    func saveAndCompare() {
        do {
            let piece = try form.validated(image: selectedImage)
            pieces.append(piece)
            persistPieces()
            Task { await saveToCloudKit(piece) }
            resetForm()
            showForm = false
        } catch {
            formError = error.localizedDescription
        }
    }

    func saveEdit() {
        guard let id = editingID else { saveAndCompare(); return }
        do {
            var updated = try form.validated(image: selectedImage)
            updated = GoldPiece(
                id:            id,
                name:          updated.name,
                store:         updated.store,
                grams:         updated.grams,
                karat:         updated.karat,
                mfgFeePercent: updated.mfgFeePercent,
                shopPrice:     updated.shopPrice,
                image:         updated.image
            )
            if let idx = pieces.firstIndex(where: { $0.id == id }) {
                pieces[idx] = updated
            }
            persistPieces()
            Task { await saveToCloudKit(updated) }
            resetForm()
            showForm = false
        } catch {
            formError = error.localizedDescription
        }
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }
        persistPieces()
        Task { await deleteFromCloudKit(id: id) }
        if editingID == id { resetForm(); showForm = false }
    }

    func deletePieces(at offsets: IndexSet) {
        let toDelete = offsets.map { pieces[$0].id }
        pieces.remove(atOffsets: offsets)
        persistPieces()
        Task {
            for id in toDelete { await deleteFromCloudKit(id: id) }
        }
    }

    // MARK: - CloudKit

    private func saveToCloudKit(_ piece: GoldPiece) async {
        let record = GoldPieceRecord.toRecord(piece)
        try? await db.save(record)
    }

    private func deleteFromCloudKit(id: UUID) async {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        try? await db.deleteRecord(withID: recordID)
    }

    func loadFromCloudKit() async {
        isSyncing = true
        defer { isSyncing = false }

        let query = CKQuery(
            recordType: GoldPieceRecord.recordType,
            predicate: NSPredicate(value: true)
        )
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        guard let results = try? await db.records(matching: query) else { return }

        let fetched = results.matchResults
            .compactMap { try? $1.get() }
            .compactMap { GoldPieceRecord.fromRecord($0) }

        guard !fetched.isEmpty else { return }

        pieces = fetched
        ComparisonStorage.save(pieces)
        NotificationCenter.default.post(name: .tojoryPiecesDidChange, object: nil)
    }

    // MARK: - Private

    private func resetForm() {
        form = .empty(); selectedImage = nil; pickerItem = nil
        formError = nil; editingID = nil
    }

    private func persistPieces() {
        ComparisonStorage.save(pieces)
        NotificationCenter.default.post(name: .tojoryPiecesDidChange, object: nil)
    }
}