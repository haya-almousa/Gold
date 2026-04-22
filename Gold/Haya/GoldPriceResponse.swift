//
//  GoldPriceResponse.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import Foundation

struct GoldPriceResponse: Decodable {
    let metal: String?
    let currency: String?
    let price: Double
    let timestamp: Int?
    let ch: Double?
    let chp: Double?
}

struct GoldQuote: Sendable {
    let price24KPerGramSAR: Double
    let price22KPerGramSAR: Double
    let price21KPerGramSAR: Double
    let price18KPerGramSAR: Double
    let usdPerGram: Double
    let changePercent: Double
    let updatedAt: Date
}
