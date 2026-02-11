//
//  War_Card_GameTests.swift
//  War Card GameTests
//
//  Created by Robert Palmer on 2/3/26.
//

import Testing
@testable import War_Card_Game

struct War_Card_GameTests {

    // MARK: - Suit Tests

    @Test func suit_hasFourCases() {
        #expect(Suit.allCases.count == 4)
    }

    @Test func suit_containsAllExpectedValues() {
        let suits = Suit.allCases
        #expect(suits.contains(.hearts))
        #expect(suits.contains(.diamonds))
        #expect(suits.contains(.clubs))
        #expect(suits.contains(.spades))
    }

    // MARK: - Rank Tests

    @Test func rank_hasThirteenCases() {
        #expect(Rank.allCases.count == 13)
    }

    @Test func rank_rawValuesAreCorrect() {
        #expect(Rank.two.rawValue == 2)
        #expect(Rank.ten.rawValue == 10)
        #expect(Rank.jack.rawValue == 11)
        #expect(Rank.queen.rawValue == 12)
        #expect(Rank.king.rawValue == 13)
        #expect(Rank.ace.rawValue == 14)
    }

    @Test func rank_comparisonWorks() {
        #expect(Rank.ace > Rank.king)
        #expect(Rank.ten > Rank.nine)
        #expect(Rank.two < Rank.three)
    }

    // MARK: - Card Tests

    @Test func card_initializesCorrectly() {
        let card = Card(suit: .hearts, rank: .queen)
        #expect(card.suit == .hearts)
        #expect(card.rank == .queen)
    }

    @Test func card_comparisonUsesRankOnly() {
        let card1 = Card(suit: .hearts, rank: .ten)
        let card2 = Card(suit: .spades, rank: .jack)
        let card3 = Card(suit: .clubs, rank: .ten)
        let card4 = Card(suit: .clubs, rank: .ten)

        #expect(card2 > card1)
        #expect(card1 != card3)
        #expect(card4 == card3)
    }
}
