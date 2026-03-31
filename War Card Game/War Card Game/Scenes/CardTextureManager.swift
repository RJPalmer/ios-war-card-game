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

    /// Cache of already-sliced textures.
    /// Key is computed from rankIndex * rows + suitIndex to uniquely identify each card.
    private var cache: [Int: SKTexture] = [:]

    private let columns = 13
    private let rows = 4

    // Padding (in pixels) around and between each card cell in the sprite sheet
    private let cellPadding: CGFloat = 11

    private let sheetPixelWidth: CGFloat
    private let sheetPixelHeight: CGFloat

    private let cardPixelWidth: CGFloat
    private let cardPixelHeight: CGFloat

    private let cardWidth: CGFloat
    private let cardHeight: CGFloat

    private init() {
        self.sheetTexture = SKTexture(imageNamed: "CardSpriteSheet")
        self.sheetTexture.filteringMode = .nearest

        let size = sheetTexture.size()

        sheetPixelWidth = size.width
        sheetPixelHeight = size.height

        // Compute the actual card pixel size accounting for padding around and between cells.
        // Assumes there is `cellPadding` on the outer edges and between each cell.
        // Total horizontal padding = (columns + 1) * cellPadding
        // Total vertical padding   = (rows + 1) * cellPadding
        let totalHorizontalPadding = CGFloat(columns + 1) * cellPadding
        let totalVerticalPadding = CGFloat(rows + 1) * cellPadding
        cardPixelWidth = (sheetPixelWidth - totalHorizontalPadding) / CGFloat(columns)
        cardPixelHeight = (sheetPixelHeight - totalVerticalPadding) / CGFloat(rows)

        // Convert pixel dimensions to normalized SpriteKit texture coordinates
        cardWidth = cardPixelWidth / sheetPixelWidth
        cardHeight = cardPixelHeight / sheetPixelHeight

        cache.reserveCapacity(52)

        // Preload all textures so gameplay never waits on slicing
        preloadAllTextures()
    }

    func texture(for rank: Rank, suit: Suit) -> SKTexture {

        if(rank.rawValue == 14){
            _ = 0
        }
        let rankIndex = rank.rawValue - 1

        guard let suitIndex = Suit.allCases.firstIndex(of: suit) else {
            fatalError("Invalid suit index")
        }

        // Safer unique cache key
        let key = suitIndex * columns + rankIndex
        if let cached = cache[key] { return cached }

        let column = rankIndex

        let visualRow = suitIndex
        let spriteRow = rows - 1 - visualRow

        // Compute pixel-space origin for this cell including padding
        let originPixelX = cellPadding + CGFloat(column) * (cardPixelWidth + cellPadding)
        let originPixelY = cellPadding + CGFloat(spriteRow) * (cardPixelHeight + cellPadding)

        // Convert to normalized texture coordinates
        let normX = originPixelX / sheetPixelWidth
        let normY = originPixelY / sheetPixelHeight
        let normW = cardPixelWidth / sheetPixelWidth
        let normH = cardPixelHeight / sheetPixelHeight

        let rect = CGRect(x: normX, y: normY, width: normW, height: normH)

        let texture = SKTexture(rect: rect, in: sheetTexture)
        texture.filteringMode = .nearest

        cache[key] = texture
        return texture
    }

    /// DEBUG: Creates a small overlay label showing the card's rank and suit.
    /// Attach this to a card node while debugging sprite sheet mapping.
    func debugLabel(for rank: Rank, suit: Suit) -> SKNode {

        let container = SKNode()

        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.fontSize = 18
        label.fontColor = .yellow
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = "\(rank) \(suit)"
        label.zPosition = 999

        let background = SKShapeNode(rectOf: CGSize(width: 120, height: 28), cornerRadius: 6)
        background.fillColor = .black
        background.alpha = 0.6
        background.strokeColor = .clear
        background.zPosition = 998

        container.addChild(background)
        container.addChild(label)

        return container
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
