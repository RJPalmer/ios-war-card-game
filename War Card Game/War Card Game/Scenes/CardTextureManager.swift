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

    // Simple slicing configuration
    private let cardPixelW: CGFloat = 138
    private let cardPixelH: CGFloat = 208
    // Use a single uniform padding between cells and as outer margins
    private let uniformPadding: CGFloat = 11
    /// If your sprite sheet is arranged bottom-to-top in rows instead of top-to-bottom,
    /// set this to false to disable row inversion.
    private let useRowInversion: Bool = true

    private let sheetPixelWidth: CGFloat
    private let sheetPixelHeight: CGFloat

    private let sheetGridW: CGFloat
    private let sheetGridH: CGFloat

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

        sheetGridW = sheetPixelWidth / CGFloat(columns)
        sheetGridH = sheetPixelHeight / CGFloat(rows)

        // Simple approach: fixed card size and uniform padding
        // Outer margins are treated as the same as inter-cell padding
        // If your sheet uses different margins, adjust `uniformPadding` or add separate margins.
        // Set the card pixel sizes to the exact known values
        cardPixelWidth = cardPixelW
        cardPixelHeight = cardPixelH

        // Convert pixel dimensions to normalized SpriteKit texture coordinates
        cardWidth = cardPixelWidth / sheetPixelWidth
        cardHeight = cardPixelHeight / sheetPixelHeight

        cache.reserveCapacity(52)

        // Preload all textures so gameplay never waits on slicing
        preloadAllTextures()
    }

    /*
     
     */
    func texture(for rank: Rank, suit: Suit) -> SKTexture {

        // MARK: - Rank Normalization (Bulletproof)
        let rankIndex: Int
        switch rank {
        case .ace:
            rankIndex = 0
        default:
            let raw = rank.rawValue
            rankIndex = max(0, min(columns - 1, raw - 1))
        }

        // MARK: - Suit Index
        guard let suitIndex = Suit.allCases.firstIndex(of: suit) else {
            assertionFailure("Invalid suit index for \(suit)")
            return fallbackTexture()
        }

        // MARK: - Cache Key
        let key = suitIndex * columns + rankIndex
        if let cached = cache[key] {
            return cached
        }

        // MARK: - Row Mapping
        let visualRow = suitIndex
        // Row inversion now handled in pixel space (SpriteKit origin is bottom-left)
        let rowIndex = visualRow

        // MARK: - Bounds Validation
        guard rankIndex >= 0 && rankIndex < columns else {
            assertionFailure("Rank index out of bounds: \(rankIndex)")
            return fallbackTexture()
        }

        guard rowIndex >= 0 && rowIndex < rows else {
            assertionFailure("Row index out of bounds: \(rowIndex)")
            return fallbackTexture()
        }

        // MARK: - Pixel-Perfect Slicing (No Bleeding, No Guesswork)
        let colF = CGFloat(rankIndex)
        let rowF = CGFloat(rowIndex)

        // Base grid positioning
        var pixelX = colF * (cardPixelWidth + uniformPadding)
        let invertedRow = CGFloat(rows - 1) - rowF
        var pixelY = invertedRow * (cardPixelHeight + uniformPadding)

        // MARK: - Per-Suit Offset Adjustment (Fine-tuning alignment)
        let suitOffset: (x: CGFloat, y: CGFloat)

        switch suit {
        case .hearts:
            suitOffset = (x: -5, y: 50)
        case .diamonds:
            suitOffset = (x: 0, y: 50)
        case .clubs:
            suitOffset = (x: 0, y: 50)
        case .spades:
            suitOffset = (x: 5, y: 50)
        }

        pixelX += suitOffset.x
        pixelY += suitOffset.y

        // Convert to normalized coordinates
        let x = pixelX / sheetPixelWidth
        let y = pixelY / sheetPixelHeight
        let w = cardPixelWidth / sheetPixelWidth
        let h = cardPixelHeight / sheetPixelHeight

        let rect = CGRect(x: x, y: y, width: w, height: h)

        // MARK: - Final Validation
        if rect.width <= 0 || rect.height <= 0 {
            assertionFailure("Invalid texture rect: \(rect)")
            return fallbackTexture()
        }

        // MARK: - Texture Creation
        let texture = SKTexture(rect: rect, in: sheetTexture)
        texture.filteringMode = .nearest
        texture.usesMipmaps = false

        cache[key] = texture

        // MARK: - Debug Hooks
        #if DEBUG
        debugLog(rank: rank, suit: suit, column: rankIndex, row: rowIndex, rect: rect)
        #endif

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

        let background = SKShapeNode(
            rectOf: CGSize(width: 120, height: 28),
            cornerRadius: 6
        )
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
    
    private func fallbackTexture() -> SKTexture {
        let size = CGSize(width: 50, height: 70)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
    
#if DEBUG
private func debugLog(rank: Rank, suit: Suit, column: Int, row: Int, rect: CGRect) {
    print("""
    🃏 Card Debug:
    - Rank: \(rank)
    - Suit: \(suit)
    - Column: \(column)
    - Row: \(row)
    - Rect: \(rect)
    """)
}
#endif
}
