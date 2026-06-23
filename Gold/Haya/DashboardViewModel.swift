//
//  DashboardViewModel.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import Combine
import Foundation
import SwiftData
internal import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var quote: GoldQuote?
    @Published private(set) var chart24KHistory: [Double]
    @Published private(set) var tojoryPieces: [GoldPieceItem] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: GoldPriceProviding
    private let cache = GoldQuoteCache()
    private let autoRefreshInterval: Duration
    private var refreshTask: Task<Void, Never>?
    private var tojoryObserver: AnyCancellable?
    @Published private(set) var chart24KSamples: [GoldChartSample]
    private var hasStarted = false

    init(
        service: GoldPriceProviding? = nil,
        autoRefreshInterval: Duration = .seconds(15)
    ) {
        self.service = service ?? GoldAPIService()
        self.autoRefreshInterval = autoRefreshInterval
        self.quote = cache.load()
        self.chart24KHistory = cache.loadHistory()
        self.chart24KSamples = cache.loadSamples()

        if let cachedQuote = self.quote, self.chart24KHistory.isEmpty {
            self.chart24KHistory = [cachedQuote.price24KPerGramSAR]
        }
        self.tojoryPieces = Self.loadTajouriPieces()

        tojoryObserver = NotificationCenter.default.publisher(for: .tajouriPiecesDidChange)
            .sink { [weak self] _ in
                self?.tojoryPieces = Self.loadTajouriPieces()
            }
    }

    deinit {
        refreshTask?.cancel()
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true

        refreshTask = Task { [weak self] in
            guard let self else { return }
            await self.refresh(showLoading: self.quote == nil)

            while !Task.isCancelled {
                try? await Task.sleep(for: self.autoRefreshInterval)
                if Task.isCancelled {
                    break
                }
                await self.refresh(showLoading: false)
            }
        }
    }

    func stop() {
        refreshTask?.cancel()
        refreshTask = nil
        hasStarted = false
    }

    func refreshManually() async {
        await refresh(showLoading: false)
    }

    func refreshOnActive() async {
        await refresh(showLoading: quote == nil)
    }

    private func refresh(showLoading: Bool) async {
        if showLoading {
            isLoading = true
        }

        defer {
            isLoading = false
        }

        do {
            let latestQuote = try await service.fetchGoldQuote()
            quote = latestQuote
            appendHistoryPoint(latestQuote.price24KPerGramSAR)
            appendSamplePoint(latestQuote)
            errorMessage = nil
            cache.save(latestQuote)
            cache.saveHistory(chart24KHistory)
            cache.saveSamples(chart24KSamples)
        } catch {
            errorMessage = "تعذر تحديث سعر الذهب المباشر حاليًا."
        }
    }

    private func appendHistoryPoint(_ value: Double) {
        let roundedValue = (value * 100).rounded() / 100
        if let last = chart24KHistory.last, abs(last - roundedValue) < 0.001 {
            return
        }
        chart24KHistory.append(roundedValue)
        if chart24KHistory.count > 24 {
            chart24KHistory.removeFirst(chart24KHistory.count - 24)
        }
    }

    private func appendSamplePoint(_ quote: GoldQuote) {
        let roundedValue = (quote.price24KPerGramSAR * 100).rounded() / 100
        if let last = chart24KSamples.last,
           abs(last.price24KPerGramSAR - roundedValue) < 0.001,
           abs(last.timestamp.timeIntervalSince(quote.updatedAt)) < 60 {
            return
        }
        chart24KSamples.append(
            GoldChartSample(
                timestamp: quote.updatedAt,
                price24KPerGramSAR: roundedValue
            )
        )
        let cutoff = Date().addingTimeInterval(-8 * 24 * 60 * 60)
        chart24KSamples.removeAll { $0.timestamp < cutoff }
    }

    var formatted24K: String {
        format(quote?.price24KPerGramSAR, decimals: 2)
    }

    var formatted22K: String {
        format(quote?.price22KPerGramSAR, decimals: 0)
    }

    var formatted21K: String {
        format(quote?.price21KPerGramSAR, decimals: 0)
    }

    var formatted18K: String {
        format(quote?.price18KPerGramSAR, decimals: 0)
    }

    var formattedUSDPerGram: String {
        format(quote?.usdPerGram, decimals: 2)
    }

    var formattedChangePercent: String {
        let value = quote?.changePercent ?? 0
        let sign = value > 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }

    var formattedPortfolioValueToday: String {
        let value = currentPortfolioValueSAR
        return formatWithGrouping(value)
    }

    var formattedWeeklyPortfolioChange: String {
        let delta = weeklyPortfolioChangeSAR
        let sign = delta >= 0 ? "+" : "-"
        let absValue = abs(delta)
        return "\(sign)\(formatWithGrouping(absValue)) هذا الاسبوع"
    }

    var weeklyPortfolioChangeIsPositive: Bool {
        weeklyPortfolioChangeSAR >= 0
    }

    var formattedTotalTojoryGrams: String {
        let total = tojoryPieces.reduce(0) { $0 + $1.weightGrams }
        return "إجمالي \(String(format: "%.0f", total)) جرام"
    }

    private var zakatablePieces: [GoldPieceItem] {
        tojoryPieces.filter { $0.condition == .unworn }
    }

    private var zakatableGrams: Double {
        zakatablePieces.reduce(0) { $0 + $1.weightGrams }
    }

    var totalGramsProgressToNisab: Double {
        guard GoldConstants.nisabGrams > 0 else { return 0 }
        return min(max(zakatableGrams / GoldConstants.nisabGrams, 0), 1)
    }

    var meetsNisab: Bool {
        zakatableGrams >= GoldConstants.nisabGrams
    }

    var nisabStatusText: String {
        meetsNisab ? "بلغ النصاب" : "لم يبلغ النصاب"
    }

    var formattedZakatDueText: String {
        guard meetsNisab, let quote else { return "زكاتك الحالية: 0.00 ريال" }
        let zakatableValue = zakatablePieces.reduce(0) { partial, piece in
            let multiplier = Double(piece.karat.rawValue) / 24.0
            return partial + piece.weightGrams * multiplier * quote.price24KPerGramSAR
        }
        let zakat = zakatableValue * 0.025
        return "زكاتك \(formatWithGrouping(zakat)) ريال"
    }

    var zakatStatusText: String {
        meetsNisab ? "الزكاة مستحقة" : "الزكاة غير مستحقة"
    }

    var changeColor: Color {
        let value = quote?.changePercent ?? 0
        if value > 0 {
            return Color("4CAF50")
        }
        if value < 0 {
            return .red
        }
        return Color("9A8A72")
    }

    var lastUpdatedText: String {
        guard let updatedAt = quote?.updatedAt else {
            return "بانتظار التحديث المباشر"
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return "آخر تحديث \(formatter.string(from: updatedAt))"
    }

    private func format(_ value: Double?, decimals: Int) -> String {
        String(format: "%.\(decimals)f", value ?? 0)
    }

    private func formatWithGrouping(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: NSNumber(value: value.rounded())) ?? "0"
    }

    private var currentPortfolioValueSAR: Double {
        guard let quote else { return 0 }
        return tojoryPieces.reduce(0) { partial, piece in
            let multiplier = Double(piece.karat.rawValue) / 24.0
            return partial + piece.weightGrams * multiplier * quote.price24KPerGramSAR
        }
    }

    private var weeklyPortfolioChangeSAR: Double {
        guard let quote else { return 0 }
        let sevenDaysAgo = Date().addingTimeInterval(-7 * 24 * 60 * 60)

        let baseline24K = historicalPrice(closestTo: sevenDaysAgo) ?? quote.price24KPerGramSAR
        let current = tojoryPieces.reduce(0) { partial, piece in
            let multiplier = Double(piece.karat.rawValue) / 24.0
            return partial + piece.weightGrams * multiplier * quote.price24KPerGramSAR
        }
        let previous = tojoryPieces.reduce(0) { partial, piece in
            let multiplier = Double(piece.karat.rawValue) / 24.0
            return partial + piece.weightGrams * multiplier * baseline24K
        }
        return current - previous
    }

    private func historicalPrice(closestTo date: Date) -> Double? {
        guard let closest = chart24KSamples.min(by: {
            abs($0.timestamp.timeIntervalSince(date)) < abs($1.timestamp.timeIntervalSince(date))
        }) else {
            return nil
        }
        return closest.price24KPerGramSAR
    }
}

private struct GoldQuoteCache {
    private let defaults = UserDefaults.standard

    private enum Key {
        static let price24K = "gold.quote.price24K"
        static let price22K = "gold.quote.price22K"
        static let price21K = "gold.quote.price21K"
        static let price18K = "gold.quote.price18K"
        static let usdPerGram = "gold.quote.usdPerGram"
        static let changePercent = "gold.quote.changePercent"
        static let updatedAt = "gold.quote.updatedAt"
        static let history24K = "gold.quote.history24K"
        static let history24KSamples = "gold.quote.history24KSamples"
    }

    func save(_ quote: GoldQuote) {
        defaults.set(quote.price24KPerGramSAR, forKey: Key.price24K)
        defaults.set(quote.price22KPerGramSAR, forKey: Key.price22K)
        defaults.set(quote.price21KPerGramSAR, forKey: Key.price21K)
        defaults.set(quote.price18KPerGramSAR, forKey: Key.price18K)
        defaults.set(quote.usdPerGram, forKey: Key.usdPerGram)
        defaults.set(quote.changePercent, forKey: Key.changePercent)
        defaults.set(quote.updatedAt, forKey: Key.updatedAt)
    }

    func load() -> GoldQuote? {
        guard let updatedAt = defaults.object(forKey: Key.updatedAt) as? Date else {
            return nil
        }

        return GoldQuote(
            price24KPerGramSAR: defaults.double(forKey: Key.price24K),
            price22KPerGramSAR: defaults.double(forKey: Key.price22K),
            price21KPerGramSAR: defaults.double(forKey: Key.price21K),
            price18KPerGramSAR: defaults.double(forKey: Key.price18K),
            usdPerGram: defaults.double(forKey: Key.usdPerGram),
            changePercent: defaults.double(forKey: Key.changePercent),
            updatedAt: updatedAt
        )
    }

    func saveHistory(_ history: [Double]) {
        defaults.set(history, forKey: Key.history24K)
    }

    func loadHistory() -> [Double] {
        defaults.array(forKey: Key.history24K) as? [Double] ?? []
    }

    func saveSamples(_ samples: [GoldChartSample]) {
        guard let data = try? JSONEncoder().encode(samples) else { return }
        defaults.set(data, forKey: Key.history24KSamples)
    }

    func loadSamples() -> [GoldChartSample] {
        guard
            let data = defaults.data(forKey: Key.history24KSamples),
            let decoded = try? JSONDecoder().decode([GoldChartSample].self, from: data)
        else {
            return []
        }
        return decoded
    }
}

struct GoldChartSample: Codable, Identifiable {
    var id: Date { timestamp }
    let timestamp: Date
    let price24KPerGramSAR: Double
}

extension Notification.Name {
    static let tajouriPiecesDidChange = Notification.Name("tajouriPiecesDidChange")
}

extension DashboardViewModel {
    @MainActor
    static func loadTajouriPieces() -> [GoldPieceItem] {
        let context = DataStore.context
        let descriptor = FetchDescriptor<PersistedTajouriPiece>(
            sortBy: [SortDescriptor(\.name)]
        )
        guard let results = try? context.fetch(descriptor) else { return [] }
        return results.compactMap { $0.toDomain() }
    }
}

extension DashboardViewModel {
    @MainActor
    static let preview: DashboardViewModel = {
        DashboardViewModel(service: MockGoldAPIService(), autoRefreshInterval: .seconds(300))
    }()
}
