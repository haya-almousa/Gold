//
//  TojoryViewModel.swift
//  Gold
//
//  Created by Rana Alqubaly on 09/11/1447 AH.
//

import Foundation
import Combine
import UIKit
internal import SwiftUI
import PhotosUI


@MainActor
final class TojoryViewModel: ObservableObject {

    // State
    @Published private(set) var pieces:       [GoldPiece]      = []
    @Published var            showForm:        Bool              = false
    @Published var            form:            AddGoldFormState  = .empty()
    @Published var            selectedImage:   UIImage?          = nil
    @Published var            pickerItem:      PhotosPickerItem? = nil
    @Published private(set) var formError:     String?           = nil
    /// Non-nil while the user is editing an existing piece
    @Published private(set) var editingID:     UUID?             = nil

    /// True when the form is being used to edit (vs. add new)
    var isEditing: Bool { editingID != nil }

    // Derived
    var bestPiece:     GoldPiece? { pieces.bestValue }
    var totalValueSAR: Double     { pieces.totalValueSAR }
    var totalGrams:    Double     { pieces.totalGrams }
    var meetsNisab:    Bool       { pieces.meetsNisab }

    // Commands
    func toggleForm() {
        if showForm { resetForm() }
        showForm.toggle()
    }

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

    /// Open the form pre-filled with an existing piece for editing
    func beginEdit(piece: GoldPiece) {
        editingID     = piece.id
        selectedImage = piece.image
        form = AddGoldFormState(
            name:       piece.name,
            store:      piece.store,
            gramsText:  piece.grams.clean,
            karat:      piece.karat,
            mfgFeeText: piece.mfgFeePercent.clean
        )
        showForm = true
    }

    /// Save a new piece (add mode)
    func saveAndCompare() {
        do {
            let piece = try form.validated(image: selectedImage)
            pieces.append(piece)
            resetForm()
            showForm = false
        } catch {
            formError = error.localizedDescription
        }
    }

    /// Commit edits to an existing piece (edit mode)
    func saveEdit() {
        guard let id = editingID else { saveAndCompare(); return }
        do {
            var updated = try form.validated(image: selectedImage)
            // Preserve original id so the list stays stable
            updated = GoldPiece(
                id:            id,
                name:          updated.name,
                store:         updated.store,
                grams:         updated.grams,
                karat:         updated.karat,
                mfgFeePercent: updated.mfgFeePercent,
                image:         updated.image
            )
            if let idx = pieces.firstIndex(where: { $0.id == id }) {
                pieces[idx] = updated
            }
            resetForm()
            showForm = false
        } catch {
            formError = error.localizedDescription
        }
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }
        if editingID == id { resetForm(); showForm = false }
    }
    func deletePieces(at offsets: IndexSet) { pieces.remove(atOffsets: offsets) }

    private func resetForm() {
        form = .empty(); selectedImage = nil; pickerItem = nil
        formError = nil; editingID = nil
    }
}
