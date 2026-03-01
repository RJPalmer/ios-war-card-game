//
//  CardTextureManager.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/26/26.
//

import Foundation
import SpriteKit

final class CardTextureManager {
    
    static let shared = CardTextureManager()
    
    private let sheetTexture: SKTexture
    private var cache: [String: SKTexture] = [:]
    
    private let columns: Int = 13
    private let rows: Int = 4
    
    private init() {
        sheetTexture = SKTexture(imageNamed: "card_spritesheet")
        sheetTexture.filteringMode = .nearest
    }
    
    func texture(for rank: Rank, suit: Suit) -> SKTexture {
        
        let column = rank.rawValue
        
        // Map suit to visual row (top-down in image)
        let visualRow: Int
        switch suit {
        case .hearts: visualRow = 0
        case .diamonds: visualRow = 1
        case .clubs: visualRow = 2
        case .spades: visualRow = 3
        }
        
        // Convert to SpriteKit coordinate system (bottom-up)
        let spriteRow = rows - 1 - visualRow
        
        let key = "\(column)-\(spriteRow)"
        if let cached = cache[key] {
            return cached
        }
        
        let width = 1.0 / CGFloat(columns)
        let height = 1.0 / CGFloat(rows)
        
        let rect = CGRect(
            x: CGFloat(column) * width,
            y: CGFloat(spriteRow) * height,
            width: width,
            height: height
        )
        
        let texture = SKTexture(rect: rect, in: sheetTexture)
        texture.filteringMode = .nearest
        
        cache[key] = texture
        return texture
    }
}
