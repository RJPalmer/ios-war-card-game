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

    private lazy var sheetTexture: SKTexture = {
        let texture = SKTexture(imageNamed: "card_spritesheet")
        texture.filteringMode = .nearest
        return texture
    }()

    /// Cache of already-sliced textures.
    /// Key is computed from rankIndex * rows + suitIndex to uniquely identify each card.
    private var cache: [Int: SKTexture] = [:]

    private let columns = 13
    private let rows = 4

    private let cardWidth: CGFloat
    private let cardHeight: CGFloat

    private init() {
        cardWidth = 1.0 / CGFloat(columns)
        cardHeight = 1.0 / CGFloat(rows)

        cache.reserveCapacity(52)

        // Preload all textures so gameplay never waits on slicing
        preloadAllTextures()
    }

    func texture(for rank: Rank, suit: Suit) -> SKTexture {
        // Convert rank to a 0...12 index (since Rank.rawValue is 2...14)
        let rankIndex = rank.rawValue - 2

        // Determine suit index using Suit.allCases order
        guard let suitIndex = Suit.allCases.firstIndex(of: suit) else {
            fatalError("Invalid suit index")
        }

        // Unique cache key for this card
        let key = rankIndex * rows + suitIndex
        if let cached = cache[key] { return cached }

        // Column corresponds to rank (0...12)
        let column = rankIndex

        // Sprite sheet rows are typically stored top→bottom, but SpriteKit
        // texture coordinates are bottom→top, so we flip the row index.
        let visualRow = suitIndex
        let spriteRow = rows - 1 - visualRow

        let rect = CGRect(
            x: CGFloat(column) * cardWidth,
            y: CGFloat(spriteRow) * cardHeight,
            width: cardWidth,
            height: cardHeight
        )

        let texture = SKTexture(rect: rect, in: sheetTexture)
        texture.filteringMode = .nearest

        cache[key] = texture
        return texture
    }

    /// Preloads all 52 card textures into the cache during initialization.
    /// This ensures that gameplay never waits for sprite slicing.
    private func preloadAllTextures() {
        for suit in Suit.allCases {
            for rank in Rank.allCases {
                _ = texture(for: rank, suit: suit)
            }
        }
    }
}
