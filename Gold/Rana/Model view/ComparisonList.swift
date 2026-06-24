//
//  ComparisonList.swift
//  Gold
//
//  Created by Rana Alqubaly on 25/11/1447 AH.
//


import Foundation
import Combine
import UIKit
import SwiftData
internal import SwiftUI

extension Notification.Name {
    static let tojoryPiecesDidChange = Notification.Name("tojoryPiecesDidChange")
}

// MARK: - Comparison List

struct GoldList: Identifiable, Equatable {
    let id:   UUID
    var name: String
}

@Model
final class PersistedGoldList {
    @Attribute(.unique) var listID: UUID
    var name:      String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, createdAt: Date = Date()) {
        self.listID    = id
        self.name      = name
        self.createdAt = createdAt
    }

    func toDomain() -> GoldList { GoldList(id: listID, name: name) }
}

// MARK: - SwiftData Model

@Model
final class PersistedComparisonPiece {
    @Attribute(.unique) var pieceID: UUID
    var name:          String
    var store:         String
    var grams:         Double
    var karatRawValue: Int
    var mfgFeePercent: Double
    var shopPrice:     Double
    var savedGoldPrice24KSAR: Double?
    var listID:        UUID?
    @Attribute(.externalStorage) var imageData: Data?

    init(from piece: GoldPiece) {
        self.pieceID       = piece.id
        self.name          = piece.name
        self.store         = piece.store
        self.grams         = piece.grams
        self.karatRawValue = piece.karat.rawValue
        self.mfgFeePercent = piece.mfgFeePercent
        self.shopPrice     = piece.shopPrice
        self.savedGoldPrice24KSAR = piece.savedGoldPrice24KSAR
        self.listID        = piece.listID
        self.imageData     = piece.image?.jpegData(compressionQuality: 0.7)
    }

    func update(from piece: GoldPiece) {
        self.name          = piece.name
        self.store         = piece.store
        self.grams         = piece.grams
        self.karatRawValue = piece.karat.rawValue
        self.mfgFeePercent = piece.mfgFeePercent
        self.shopPrice     = piece.shopPrice
        self.savedGoldPrice24KSAR = piece.savedGoldPrice24KSAR
        self.listID        = piece.listID
        self.imageData     = piece.image?.jpegData(compressionQuality: 0.7)
    }

    func toDomain() -> GoldPiece? {
        guard let karat = Karat(rawValue: karatRawValue) else { return nil }

        var image: UIImage?
        if let data = imageData {
            image = UIImage(data: data)
        }

        return GoldPiece(
            id:            pieceID,
            name:          name,
            store:         store,
            grams:         grams,
            karat:         karat,
            mfgFeePercent: mfgFeePercent,
            shopPrice:     shopPrice,
            savedGoldPrice24KSAR: savedGoldPrice24KSAR,
            listID:        listID,
            image:         image
        )
    }
}

// MARK: - ViewModel

@MainActor
final class ComparisonListViewModel: ObservableObject {

    @Published private(set) var pieces:              [GoldPiece]      = []
    @Published var            showForm:               Bool              = false
    @Published var            form:                   AddGoldFormState  = .empty()
    @Published var            selectedImage:          UIImage?          = nil
    @Published private(set) var nameError:            String?           = nil
    @Published private(set) var gramsError:           String?           = nil
    @Published private(set) var priceError:           String?           = nil
    @Published private(set) var editingID:            UUID?             = nil
    @Published private(set) var editingListID:        UUID?             = nil
    @Published private(set) var isSyncing:            Bool              = false
    @Published private(set) var liveGoldPrice24KSAR:  Double?
    @Published private(set) var lists:                [GoldList]        = []
    @Published var            selectedListID:         UUID?             = nil

    private let apiService        = GoldAPIService()
    private var priceRefreshTask: Task<Void, Never>?
    private let modelContext: ModelContext

    var isEditing: Bool { editingID != nil }

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext ?? DataStore.context
        pieces = Self.loadPieces(from: self.modelContext)
        lists  = Self.loadLists(from: self.modelContext)
        startLivePriceUpdates()
    }

    deinit {
        priceRefreshTask?.cancel()
    }

    var bestPiece: GoldPiece? {
        guard pieces.count >= 2 else { return nil }
        if let livePrice = liveGoldPrice24KSAR {
            return pieces.min(by: { $0.liveTotalWithVAT(price24KSAR: livePrice) < $1.liveTotalWithVAT(price24KSAR: livePrice) })
        }
        let withPrice = pieces.filter { $0.shopPrice > 0 }
        if !withPrice.isEmpty {
            return withPrice.min(by: { $0.shopTotalWithVAT < $1.shopTotalWithVAT })
        }
        return pieces.bestValue
    }

    var totalValueSAR: Double {
        guard let livePrice = liveGoldPrice24KSAR else { return pieces.totalValueSAR }
        return pieces.reduce(0) { $0 + $1.liveValueSAR(price24KSAR: livePrice) }
    }

    var totalGrams: Double  { pieces.totalGrams }
    var meetsNisab: Bool    { pieces.meetsNisab }

    func toggleForm() {
        if showForm { resetForm() }
        showForm.toggle()
    }

    func cancelForm() { resetForm(); showForm = false }

    func updateField<T>(_ keyPath: WritableKeyPath<AddGoldFormState, T>, value: T) {
        form[keyPath: keyPath] = value
        nameError = nil; gramsError = nil; priceError = nil
    }

    func beginEdit(piece: GoldPiece) {
        editingID     = piece.id
        editingListID = piece.listID
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

    func saveAndCompare(listID: UUID? = nil) {
        do {
            var piece = try form.validated(image: selectedImage)
            piece.savedGoldPrice24KSAR = liveGoldPrice24KSAR
            piece.listID = listID
            pieces.append(piece)
            persistSave(piece)
            resetForm()
            showForm = false
        } catch let e as FormValidationError {
            switch e {
            case .emptyName:    nameError  = e.localizedDescription
            case .invalidGrams: gramsError = e.localizedDescription
            case .invalidPrice: priceError = e.localizedDescription
            }
        } catch {
            nameError = error.localizedDescription
        }
    }

    func saveEdit(listID: UUID? = nil) {
        guard let id = editingID else { saveAndCompare(listID: listID); return }
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
                savedGoldPrice24KSAR: liveGoldPrice24KSAR,
                listID:        listID ?? editingListID,
                image:         updated.image
            )
            if let idx = pieces.firstIndex(where: { $0.id == id }) {
                pieces[idx] = updated
            }
            persistUpdate(updated)
            resetForm()
            showForm = false

        } catch let e as FormValidationError {
            switch e {
            case .emptyName:    nameError  = e.localizedDescription
            case .invalidGrams: gramsError = e.localizedDescription
            case .invalidPrice: priceError = e.localizedDescription
            }
        } catch {
            nameError = error.localizedDescription
        }
    }

    // MARK: - Lists

    func createList(name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let list = GoldList(id: UUID(), name: trimmed)
        lists.append(list)
        persistList(list)
    }

    func toggleListFilter(_ id: UUID) {
        selectedListID = (selectedListID == id) ? nil : id
    }

    func deleteList(id: UUID) {
        let idsToRemove = pieces.filter { $0.listID == id }.map { $0.id }
        pieces.removeAll { $0.listID == id }
        for pieceID in idsToRemove { persistDelete(id: pieceID) }

        lists.removeAll { $0.id == id }
        persistDeleteList(id: id)

        if selectedListID == id { selectedListID = nil }
        if let editingID, idsToRemove.contains(editingID) { resetForm(); showForm = false }
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }
        persistDelete(id: id)
        if editingID == id { resetForm(); showForm = false }
    }

    func deletePieces(at offsets: IndexSet) {
        let toDelete = offsets.map { pieces[$0].id }
        pieces.remove(atOffsets: offsets)
        for id in toDelete { persistDelete(id: id) }
    }

    // MARK: - Save to Tajouri

    func saveToTajouri(_ piece: GoldPiece) {
        let item = GoldPieceItem(
            name:          piece.name,
            weightGrams:   piece.grams,
            karat:         GoldKarat(rawValue: piece.karat.rawValue) ?? .k21,
            condition:     .worn,
            purchasePrice: piece.shopTotalWithVAT,
            imageData:     piece.image?.jpegData(compressionQuality: 0.7)
        )
        let persisted = PersistedTajouriPiece(from: item)
        modelContext.insert(persisted)
        try? modelContext.save()
        NotificationCenter.default.post(name: .tajouriPiecesDidChange, object: nil)
    }

    // MARK: - Live Gold Price

    private func startLivePriceUpdates() {
        priceRefreshTask = Task {
            await fetchLivePrice()
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
                if Task.isCancelled { break }
                await fetchLivePrice()
            }
        }
    }

    func refreshLivePrice() {
        Task { await fetchLivePrice() }
    }

    private func fetchLivePrice() async {
        if let quote = try? await apiService.fetchGoldQuote() {
            let newPrice = quote.price24KPerGramSAR
            liveGoldPrice24KSAR = newPrice
            backfillBaselines(currentPrice: newPrice)
        }
    }

    private func backfillBaselines(currentPrice: Double) {
        var changed = false
        for i in pieces.indices where pieces[i].savedGoldPrice24KSAR == nil {
            pieces[i].savedGoldPrice24KSAR = currentPrice
            changed = true
        }
        if changed { persistAll() }
    }

    // MARK: - SwiftData Persistence

    private func persistSave(_ piece: GoldPiece) {
        let persisted = PersistedComparisonPiece(from: piece)
        modelContext.insert(persisted)
        try? modelContext.save()
        NotificationCenter.default.post(name: .tojoryPiecesDidChange, object: nil)
    }

    private func persistUpdate(_ piece: GoldPiece) {
        let id = piece.id
        let predicate = #Predicate<PersistedComparisonPiece> { $0.pieceID == id }
        if let existing = try? modelContext.fetch(FetchDescriptor(predicate: predicate)).first {
            existing.update(from: piece)
            try? modelContext.save()
        }
        NotificationCenter.default.post(name: .tojoryPiecesDidChange, object: nil)
    }

    private func persistDelete(id: UUID) {
        let predicate = #Predicate<PersistedComparisonPiece> { $0.pieceID == id }
        if let existing = try? modelContext.fetch(FetchDescriptor(predicate: predicate)).first {
            modelContext.delete(existing)
            try? modelContext.save()
        }
        NotificationCenter.default.post(name: .tojoryPiecesDidChange, object: nil)
    }

    private func persistAll() {
        for piece in pieces {
            let id = piece.id
            let predicate = #Predicate<PersistedComparisonPiece> { $0.pieceID == id }
            if let existing = try? modelContext.fetch(FetchDescriptor(predicate: predicate)).first {
                existing.update(from: piece)
            }
        }
        try? modelContext.save()
    }

    private static func loadPieces(from context: ModelContext) -> [GoldPiece] {
        let descriptor = FetchDescriptor<PersistedComparisonPiece>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let results = try? context.fetch(descriptor) else { return [] }
        return results.compactMap { $0.toDomain() }
    }

    private func persistList(_ list: GoldList) {
        let persisted = PersistedGoldList(id: list.id, name: list.name)
        modelContext.insert(persisted)
        try? modelContext.save()
    }

    private static func loadLists(from context: ModelContext) -> [GoldList] {
        let descriptor = FetchDescriptor<PersistedGoldList>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        guard let results = try? context.fetch(descriptor) else { return [] }
        return results.map { $0.toDomain() }
    }

    private func persistDeleteList(id: UUID) {
        let predicate = #Predicate<PersistedGoldList> { $0.listID == id }
        if let existing = try? modelContext.fetch(FetchDescriptor(predicate: predicate)).first {
            modelContext.delete(existing)
            try? modelContext.save()
        }
    }

    // MARK: - Private

    private func resetForm() {
        form = .empty(); selectedImage = nil
        nameError = nil; gramsError = nil; priceError = nil
        editingID = nil; editingListID = nil
    }
}
