//
//  GoldAPIService.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import Foundation

protocol GoldPriceProviding: Sendable {
    func fetchGoldQuote() async throws -> GoldQuote
}

struct GoldAPIService: GoldPriceProviding {
    private let session: URLSession
    private let endpoint = URL(string: "https://api.gold-api.com/price/XAU")!
    private let usdToSARRate = 3.75
    private let gramsPerTroyOunce = 31.1034768

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchGoldQuote() async throws -> GoldQuote {
        var request = URLRequest(url: endpoint)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 15

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200 ... 299 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        let payload = try JSONDecoder().decode(GoldPriceResponse.self, from: data)

        let usdPerOunce = payload.price
        let sarPerOunce = usdPerOunce * usdToSARRate
        let usdPerGram = usdPerOunce / gramsPerTroyOunce
        let sar24KPerGram = sarPerOunce / gramsPerTroyOunce

        let updatedAt: Date
        if let timestamp = payload.timestamp {
            updatedAt = Date(timeIntervalSince1970: TimeInterval(timestamp))
        } else {
            updatedAt = Date()
        }

        return GoldQuote(
            price24KPerGramSAR: sar24KPerGram,
            price22KPerGramSAR: sar24KPerGram * (22.0 / 24.0),
            price21KPerGramSAR: sar24KPerGram * (21.0 / 24.0),
            price18KPerGramSAR: sar24KPerGram * (18.0 / 24.0),
            usdPerGram: usdPerGram,
            changePercent: payload.chp ?? 0,
            updatedAt: updatedAt
        )
    }
}

struct MockGoldAPIService: GoldPriceProviding {
    func fetchGoldQuote() async throws -> GoldQuote {
        GoldQuote(
            price24KPerGramSAR: 369.07,
            price22KPerGramSAR: 338.31,
            price21KPerGramSAR: 322.93,
            price18KPerGramSAR: 276.80,
            usdPerGram: 98.42,
            changePercent: 0.83,
            updatedAt: Date()
        )
    }
}
