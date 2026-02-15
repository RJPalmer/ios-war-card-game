//
//  Player.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

struct Player {
    
    private(set) var name:String
    private var deck: ArraySlice<Card>
    
    init(name: String = "", cards: [Card] = []) {
        self.name = name
        self.deck = ArraySlice(cards)
    }
    
    // MARK: - Public API
    
    var cardCount: Int {
        return deck.count
    }
    
    var isEmpty: Bool {
        return deck.isEmpty
    }
    
    mutating func drawCard() -> Card? {
        guard let first = deck.first else { return nil }
        deck = deck.dropFirst()
        return first
    }
    
    mutating func receiveCard(_ newCard: Card) {
        deck.append(newCard)
    }
    mutating func receiveCards(_ newCards: [Card]) {
        deck.append(contentsOf: newCards)
    }
    mutating func setCards(_ newCards: [Card]) {
        self.deck = ArraySlice(newCards)
    }
}
