//
//  CardNode.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/26/26.
//

import Foundation
import SpriteKit

final class CardNode: SKSpriteNode {
    
    let rank: Rank
    let suit: Suit
    
    init(rank: Rank, suit: Suit) {
        self.rank = rank
        self.suit = suit
        
        let texture = CardTextureManager.shared.texture(for: rank, suit: suit)
        super.init(texture: texture, color: .clear, size: texture.size())
        
        self.name = "\(rank)-\(suit)"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}   
    
