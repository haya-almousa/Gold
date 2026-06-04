//
//  SubscriptionManager.swift
//  Gold
//

import Combine
import StoreKit
import Foundation

@MainActor
final class SubscriptionManager: ObservableObject {

    static let shared = SubscriptionManager()

    static let groupID = "22097645"
    static let monthlyID = "tabrah.premium.monthly"

    @Published private(set) var isPremium: Bool = false
    @Published private(set) var currentSubscription: Product?

    private var updateTask: Task<Void, Never>?

    private init() {
        updateTask = Task { await listenForUpdates() }
        Task { await refreshStatus() }
    }

    deinit {
        updateTask?.cancel()
    }

    func refreshStatus() async {
        var foundActive = false

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               transaction.productID == Self.monthlyID,
               transaction.revocationDate == nil {
                foundActive = true
                break
            }
        }

        isPremium = foundActive

        if let product = try? await Product.products(for: [Self.monthlyID]).first {
            currentSubscription = product
        }
    }

    private func listenForUpdates() async {
        for await result in Transaction.updates {
            if case .verified(let transaction) = result {
                await transaction.finish()
                await refreshStatus()
            }
        }
    }
}
