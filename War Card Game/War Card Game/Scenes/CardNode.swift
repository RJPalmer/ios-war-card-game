//
//  CardNode.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/26/26.
//

import Foundation
import SpriteKit

final class CardNode: SKSpriteNode {
    
    // MARK: - Shared Textures
    
    /// Cached card back texture to avoid repeated loading
    private static let backTexture = SKTexture(imageNamed: "card_back")
    
    /// Key used to prevent multiple flip animations running simultaneously
    private static let flipActionKey = "card_flip"
    
    // MARK: - Card Identity
    
    let rank: Rank
    let suit: Suit
    
    // MARK: - Constants
    
    static let defaultSize = CGSize(width: 80, height: 120)
    
    // MARK: - State
    
    private(set) var isFaceUp: Bool = true
    
    // MARK: - Initializer
    
    init(rank: Rank, suit: Suit) {
        
        self.rank = rank
        self.suit = suit
        
        let texture = CardTextureManager.shared.texture(for: rank, suit: suit)
        
        super.init(texture: texture, color: .clear, size: CardNode.defaultSize)
        
#if DEBUG
        // Development overlay showing rank and suit to verify sprite slicing
        let label = CardNode.debugLabel(for: rank, suit: suit)
        addChild(label)
#endif
        
        name = "card_\(rank.shortCode)_\(suit.shortCode)"
        
        zPosition = 10
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Flip Animation
    
    func flip(duration: TimeInterval = 0.25) {
        
        // Prevent overlapping flip animations
        if action(forKey: CardNode.flipActionKey) != nil { return }
        
        let firstHalf = SKAction.scaleX(to: 0.0, duration: duration / 2)
        
        let changeTexture = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            if self.isFaceUp {
                self.texture = CardNode.backTexture
            } else {
                self.texture = CardTextureManager.shared.texture(for: self.rank, suit: self.suit)
            }
            
            self.isFaceUp.toggle()
        }
        
        let secondHalf = SKAction.scaleX(to: 1.0, duration: duration / 2)
        
        let sequence = SKAction.sequence([firstHalf, changeTexture, secondHalf])
        
        run(sequence, withKey: CardNode.flipActionKey)
    }
    
    // MARK: - Movement
    
    func move(to position: CGPoint,
              duration: TimeInterval = 0.3,
              completion: (() -> Void)? = nil) {
        
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        
        if let completion {
            run(SKAction.sequence([moveAction, .run(completion)]))
        } else {
            run(moveAction)
        }
    }
    
    // MARK: - Highlight (optional)
    
    func highlight(_ enabled: Bool) {
        color = .yellow
        colorBlendFactor = enabled ? 0.3 : 0.0
    }
    
    // MARK: - Face State Control
    
    /// Sets the face state without performing a flip animation.
    func setFaceUp(_ faceUp: Bool) {
        isFaceUp = faceUp
        
        if faceUp {
            texture = CardTextureManager.shared.texture(for: rank, suit: suit)
        } else {
            texture = CardNode.backTexture
        }
    }
    
    // MARK: - Debug Label (Development Only)
    
    /// Small overlay label used during development to confirm
    /// that the correct rank/suit texture is being displayed.
    private static func debugLabel(for rank: Rank, suit: Suit) -> SKNode {
        
        let container = SKNode()
        container.name = "debugLabel"
        container.zPosition = 1000
        
        let label = SKLabelNode(fontNamed: "Menlo")
        label.text = "\(rank.shortCode) \(suit.shortCode)"
        label.fontSize = 10
        label.fontColor = .red
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        
        // Slight upward offset so it sits near the top of the card
        label.position = CGPoint(x: 0, y: CardNode.defaultSize.height * 0.35)
        
        container.addChild(label)
        return container
    }
}

