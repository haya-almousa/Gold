//
//  Item.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import Foundation
import SwiftData

enum DataStore {
    static let shared: ModelContainer = {
        let schema = Schema([
            PersistedTajouriPiece.self,
            PersistedComparisonPiece.self,
            PersistedGoldList.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        return try! ModelContainer(for: schema, configurations: [config])
    }()

    @MainActor
    static var context: ModelContext {
        shared.mainContext
    }
}
