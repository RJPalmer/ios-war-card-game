//
//  Deck.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

struct Deck {
    private(set) var cards: [Card] = []

    init() {
        buildDeck()
        shuffle()
    }

    // MARK: - Deck Setup

    private mutating func buildDeck() {
        cards = Suit.allCases.flatMap { suit in
            Rank.allCases.map { rank in
                Card(suit: suit, rank: rank)
            }
        }
    }

    mutating func shuffle() {
        cards.shuffle()
    }

    // MARK: - Drawing Cards

    mutating func drawCard() -> Card? {
        guard !cards.isEmpty else { return nil }
        return cards.removeFirst()
    }

    // MARK: - Dealing

    mutating func dealEvenly() -> ([Card], [Card]) {
        var playerOne: [Card] = []
        var playerTwo: [Card] = []

        while !cards.isEmpty {
            if let card1 = drawCard() {
                playerOne.append(card1)
            }
            if let card2 = drawCard() {
                playerTwo.append(card2)
            }
        }

        return (playerOne, playerTwo)
    }
}
