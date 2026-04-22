//
//  Item.swift
//  Gold
//
//  Created by Haya almousa on 22/04/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
