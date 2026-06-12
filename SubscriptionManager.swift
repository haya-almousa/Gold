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

    // TODO: Re-enable StoreKit subscriptions after first App Store release
    @Published private(set) var isPremium: Bool = true
    @Published private(set) var currentSubscription: Product?

    private init() {}

    func refreshStatus() async {}
}
