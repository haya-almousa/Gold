//
//  Tajouriviewmodel.swift
//  Gold
//
//  Created by Raghad Alamoudi on 02/12/1447 AH.
//



import Combine
import Foundation
import SwiftData
internal import SwiftUI

@MainActor
final class TajouriViewModel: ObservableObject {

    // MARK: - Published

    @Published private(set) var price24KPerGramSAR: Double          = 0
    @Published private(set) var isLoading:          Bool            = true
    @Published private(set) var isSyncing:          Bool            = false
    @Published private(set) var pieces:             [GoldPieceItem] = []

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()
    private var modelContext: ModelContext

    // MARK: - Init

    init(dashboardVM: DashboardViewModel, modelContext: ModelContext? = nil) {

        self.modelContext = modelContext ?? DataStore.context

        // 1) تحميل البيانات من SwiftData
        pieces = Self.loadPieces(from: self.modelContext)

        // 2) سعر الذهب من DashboardVM
        if let quote = dashboardVM.quote {
            price24KPerGramSAR = quote.price24KPerGramSAR
            isLoading = false
        }

        dashboardVM.$quote
            .receive(on: DispatchQueue.main)
            .sink { [weak self] quote in
                guard let self, let quote else { return }

                self.price24KPerGramSAR = quote.price24KPerGramSAR
                self.isLoading = false
            }
            .store(in: &cancellables)
    }

    // MARK: - Zakat Eligible Pieces

    private var zakatablePieces: [GoldPieceItem] {
        pieces.filter { $0.condition == .unworn }
    }

    // MARK: - Portfolio (All Pieces)

    var totalPortfolioValueSAR: Double {
        guard price24KPerGramSAR > 0 else { return 0 }

        return pieces.reduce(0) { partialResult, piece in
            partialResult + currentValue(of: piece)
        }
    }

    var totalGrams: Double {
        pieces.reduce(0) { partialResult, piece in
            partialResult + piece.weightGrams
        }
    }

    // MARK: - Zakat Calculations (Only Unworn Gold)

    var zakatableGrams: Double {
        zakatablePieces.reduce(0) { partialResult, piece in
            partialResult + piece.weightGrams
        }
    }

    var zakatableValueSAR: Double {
        guard price24KPerGramSAR > 0 else { return 0 }

        return zakatablePieces.reduce(0) { partialResult, piece in
            partialResult + currentValue(of: piece)
        }
    }

    var meetsNisab: Bool {
        zakatableGrams >= GoldConstants.nisabGrams
    }

    var zakatDueSAR: Double {
        guard meetsNisab else { return 0 }

        return zakatableValueSAR * 0.025
    }

    // MARK: - Gold Helpers

    func currentValue(of piece: GoldPieceItem) -> Double {
        guard price24KPerGramSAR > 0 else {
            return piece.purchasePrice
        }

        let multiplier = Double(piece.karat.rawValue) / 24.0

        return piece.weightGrams * multiplier * price24KPerGramSAR
    }

    func pricePerGram(for karat: GoldKarat) -> Double {
        price24KPerGramSAR * (Double(karat.rawValue) / 24.0)
    }

    func gainLoss(of piece: GoldPieceItem) -> Double {
        currentValue(of: piece) - piece.purchasePrice
    }

    // MARK: - CRUD

    func addPiece(_ piece: GoldPieceItem) {
        pieces.insert(piece, at: 0)
        let persisted = PersistedTajouriPiece(from: piece)
        modelContext.insert(persisted)
        try? modelContext.save()
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }

        let predicate = #Predicate<PersistedTajouriPiece> { $0.pieceID == id }
        if let existing = try? modelContext.fetch(FetchDescriptor(predicate: predicate)).first {
            modelContext.delete(existing)
            try? modelContext.save()
        }
    }

    func updatePiece(_ updated: GoldPieceItem) {
        guard let index = pieces.firstIndex(where: { $0.id == updated.id }) else {
            return
        }

        pieces[index] = updated

        let id = updated.id
        let predicate = #Predicate<PersistedTajouriPiece> { $0.pieceID == id }
        if let existing = try? modelContext.fetch(FetchDescriptor(predicate: predicate)).first {
            existing.update(from: updated)
            try? modelContext.save()
        }
    }

    // MARK: - SwiftData Load

    private static func loadPieces(from context: ModelContext) -> [GoldPieceItem] {
        let descriptor = FetchDescriptor<PersistedTajouriPiece>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let results = try? context.fetch(descriptor) else { return [] }
        return results.compactMap { $0.toDomain() }
    }
}
