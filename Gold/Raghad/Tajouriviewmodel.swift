//
//  Tajouriviewmodel.swift
//  Gold
//
//  Created by Raghad Alamoudi on 02/12/1447 AH.
//


import Combine
import Foundation
import CloudKit
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

    // نفس الـ privateCloudDatabase في ComparisonListViewModel
    private let db = CKContainer(identifier: "iCloud.HayaAlmousa.Gold")
                        .privateCloudDatabase

    // MARK: - Init

    init(dashboardVM: DashboardViewModel) {
        // 1) حمّل من UserDefaults أولاً (نفس ComparisonListViewModel.init)
        pieces = TajouriLocalStorage.load()

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

        // 3) زامن مع CloudKit في الخلفية (نفس ComparisonListViewModel.init)
        Task { await loadFromCloudKit() }
    }

    // MARK: - Computed: Portfolio

    var totalPortfolioValueSAR: Double {
        guard price24KPerGramSAR > 0 else { return 0 }
        return pieces.reduce(0) { $0 + currentValue(of: $1) }
    }

    var totalGrams: Double {
        pieces.reduce(0) { $0 + $1.weightGrams }
    }

    func currentValue(of piece: GoldPieceItem) -> Double {
        guard price24KPerGramSAR > 0 else { return piece.purchasePrice }
        let multiplier = Double(piece.karat.rawValue) / 24.0
        return piece.weightGrams * multiplier * price24KPerGramSAR
    }

    func pricePerGram(for karat: GoldKarat) -> Double {
        price24KPerGramSAR * (Double(karat.rawValue) / 24.0)
    }

    func gainLoss(of piece: GoldPieceItem) -> Double {
        currentValue(of: piece) - piece.purchasePrice
    }

    // MARK: - Computed: Zakat

    var meetsNisab: Bool {
        totalGrams >= GoldConstants.nisabGrams
    }

    var zakatDueSAR: Double {
        guard meetsNisab else { return 0 }
        return totalPortfolioValueSAR * 0.025
    }

    // MARK: - CRUD

    func addPiece(_ piece: GoldPieceItem) {
        pieces.insert(piece, at: 0)
        persistPieces()
        Task { await saveToCloudKit(piece) }
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }
        persistPieces()
        Task { await deleteFromCloudKit(id: id) }
    }

    func updatePiece(_ updated: GoldPieceItem) {
        guard let index = pieces.firstIndex(where: { $0.id == updated.id }) else { return }
        pieces[index] = updated
        persistPieces()
        Task { await saveToCloudKit(updated) }
    }

    // MARK: - CloudKit: Save

    private func saveToCloudKit(_ piece: GoldPieceItem) async {
        let record = TajouriCloudRecord.toRecord(piece)
        try? await db.save(record)
    }

    // MARK: - CloudKit: Delete

    private func deleteFromCloudKit(id: UUID) async {
        let recordID = CKRecord.ID(recordName: id.uuidString)
        try? await db.deleteRecord(withID: recordID)
    }

    // MARK: - CloudKit: Load (نفس loadFromCloudKit في ComparisonListViewModel)

    func loadFromCloudKit() async {
        isSyncing = true
        defer { isSyncing = false }

        let query = CKQuery(
            recordType: TajouriCloudRecord.recordType,
            predicate:  NSPredicate(value: true)
        )
        query.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        guard let results = try? await db.records(matching: query) else { return }

        let fetched = results.matchResults
            .compactMap { try? $1.get() }
            .compactMap { TajouriCloudRecord.fromRecord($0) }

        guard !fetched.isEmpty else { return }

        // CloudKit هو المصدر الأساسي — نفس المنطق في ComparisonListViewModel
        pieces = fetched
        TajouriLocalStorage.save(pieces)
    }

    // MARK: - Private

    // نفس persistPieces في ComparisonListViewModel
    private func persistPieces() {
        TajouriLocalStorage.save(pieces)
    }
}
