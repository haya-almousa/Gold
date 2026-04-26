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
    @Published private(set) var pieces:       [GoldPiece]     = []
    @Published var            showForm:        Bool             = false
    @Published var            form:            AddGoldFormState = .empty()
    @Published var            selectedImage:   UIImage?         = nil
    @Published var            pickerItem:      PhotosPickerItem? = nil
    @Published private(set) var formError:     String?          = nil

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

    func deletePiece(id: UUID)            { pieces.removeAll { $0.id == id } }
    func deletePieces(at offsets: IndexSet) { pieces.remove(atOffsets: offsets) }

    private func resetForm() {
        form = .empty(); selectedImage = nil; pickerItem = nil; formError = nil
    }
}

