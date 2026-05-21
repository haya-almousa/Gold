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

        // 1) تحميل البيانات المحلية أولاً
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

        // 3) مزامنة CloudKit بالخلفية
        Task {
            await loadFromCloudKit()
        }
    }

    // MARK: - Zakat Eligible Pieces

    /// فقط الذهب غير الملبوس يدخل في حساب الزكاة
    private var zakatablePieces: [GoldPieceItem] {
        pieces.filter { $0.condition == .unworn }
    }

    // MARK: - Portfolio (All Pieces)

    /// إجمالي قيمة جميع قطع الذهب (ملبوس + غير ملبوس)
    var totalPortfolioValueSAR: Double {
        guard price24KPerGramSAR > 0 else { return 0 }

        return pieces.reduce(0) { partialResult, piece in
            partialResult + currentValue(of: piece)
        }
    }

    /// إجمالي وزن جميع القطع
    var totalGrams: Double {
        pieces.reduce(0) { partialResult, piece in
            partialResult + piece.weightGrams
        }
    }

    // MARK: - Zakat Calculations (Only Unworn Gold)

    /// الوزن الخاضع للزكاة فقط
    var zakatableGrams: Double {
        zakatablePieces.reduce(0) { partialResult, piece in
            partialResult + piece.weightGrams
        }
    }

    /// القيمة الحالية للذهب الخاضع للزكاة فقط
    var zakatableValueSAR: Double {
        guard price24KPerGramSAR > 0 else { return 0 }

        return zakatablePieces.reduce(0) { partialResult, piece in
            partialResult + currentValue(of: piece)
        }
    }

    /// هل بلغ الذهب غير الملبوس النصاب؟
    var meetsNisab: Bool {
        zakatableGrams >= GoldConstants.nisabGrams
    }

    /// الزكاة المستحقة على الذهب غير الملبوس فقط
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

        persistPieces()

        Task {
            await saveToCloudKit(piece)
        }
    }

    func deletePiece(id: UUID) {
        pieces.removeAll { $0.id == id }

        persistPieces()

        Task {
            await deleteFromCloudKit(id: id)
        }
    }

    func updatePiece(_ updated: GoldPieceItem) {
        guard let index = pieces.firstIndex(where: { $0.id == updated.id }) else {
            return
        }

        pieces[index] = updated

        persistPieces()

        Task {
            await saveToCloudKit(updated)
        }
    }

    // MARK: - CloudKit Save

    private func saveToCloudKit(_ piece: GoldPieceItem) async {
        let record = TajouriCloudRecord.toRecord(piece)

        try? await db.save(record)
    }

    // MARK: - CloudKit Delete

    private func deleteFromCloudKit(id: UUID) async {
        let recordID = CKRecord.ID(recordName: id.uuidString)

        try? await db.deleteRecord(withID: recordID)
    }

    // MARK: - CloudKit Load

    func loadFromCloudKit() async {

        isSyncing = true

        defer {
            isSyncing = false
        }

        let query = CKQuery(
            recordType: TajouriCloudRecord.recordType,
            predicate: NSPredicate(value: true)
        )

        query.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        guard let results = try? await db.records(matching: query) else {
            return
        }

        let fetched = results.matchResults
            .compactMap { try? $1.get() }
            .compactMap { TajouriCloudRecord.fromRecord($0) }

        guard !fetched.isEmpty else {
            return
        }

        // CloudKit هو المصدر الأساسي
        pieces = fetched

        TajouriLocalStorage.save(pieces)
    }

    // MARK: - Local Persistence

    private func persistPieces() {
        TajouriLocalStorage.save(pieces)
    }
}
