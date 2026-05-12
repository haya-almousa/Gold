//
//  StoredGoldPiece.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


import Foundation
import Combine
import UIKit
internal import SwiftUI
import PhotosUI

extension Notification.Name {
    static let tojoryPiecesDidChange = Notification.Name("tojoryPiecesDidChange")
}

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

@MainActor
final class ComparisonListViewModel: ObservableObject {

    @Published private(set) var pieces:        [GoldPiece]      = []
    @Published var            showForm:         Bool              = false
    @Published var            form:             AddGoldFormState  = .empty()
    @Published var            selectedImage:    UIImage?          = nil
    @Published var            pickerItem:       PhotosPickerItem? = nil
    @Published private(set) var formError:      String?           = nil
    @Published private(set) var editingID:      UUID?             = nil

    var isEditing: Bool { editingID != nil }

    init() { pieces = ComparisonStorage.load() }

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
            resetForm()
            showForm = false
        } catch {
            formError = error.localizedDescription
        }
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }
        persistPieces()
        if editingID == id { resetForm(); showForm = false }
    }

    func deletePieces(at offsets: IndexSet) {
        pieces.remove(atOffsets: offsets)
        persistPieces()
    }

    private func resetForm() {
        form = .empty(); selectedImage = nil; pickerItem = nil
        formError = nil; editingID = nil
    }

    private func persistPieces() {
        ComparisonStorage.save(pieces)
        NotificationCenter.default.post(name: .tojoryPiecesDidChange, object: nil)
    }
}