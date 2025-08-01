//
//  Item.swift
//  New Fantasy App Idea
//
//  Created by Hamza on 7/31/25.
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
