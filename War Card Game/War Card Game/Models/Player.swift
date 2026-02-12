//
//  Player.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

struct Player {
    
    private(set) var cards: [Card]
    
    init(cards: [Card] = []) {
        self.cards = cards
    }
    
    // MARK: - Public API
    
    var cardCount: Int {
        return cards.count
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
    
    mutating func drawCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }
    
    mutating func receiveCard(_ newCard: Card){
        cards.append(newCard)
    }
    mutating func receiveCards(_ newCards: [Card]) {
        cards.append(contentsOf: newCards)
    }
}
