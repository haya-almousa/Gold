//
//  DashboardViewModel.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published private(set) var quote: GoldQuote?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let service: GoldPriceProviding
    private let cache = GoldQuoteCache()
    private let autoRefreshInterval: Duration
    private var refreshTask: Task<Void, Never>?
    private var hasStarted = false

    init(
        service: GoldPriceProviding? = nil,
        autoRefreshInterval: Duration = .seconds(15)
    ) {
        self.service = service ?? GoldAPIService()
        self.autoRefreshInterval = autoRefreshInterval
        self.quote = cache.load()
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
            errorMessage = nil
            cache.save(latestQuote)
        } catch {
            errorMessage = "تعذر تحديث سعر الذهب المباشر حاليًا."
        }
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

    var changeColor: Color {
        let value = quote?.changePercent ?? 0
        if value > 0 {
            return .profit
        }
        if value < 0 {
            return .red
        }
        return .secondaryInk
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
}

extension DashboardViewModel {
    @MainActor
    static let preview: DashboardViewModel = {
        DashboardViewModel(service: MockGoldAPIService(), autoRefreshInterval: .seconds(300))
    }()
}
