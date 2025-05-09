//
//  Item.swift
//  ArtifyAI
//
//  Created by Dilber Şah on 8.05.2025.
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
