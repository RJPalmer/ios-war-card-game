//
//  PlayerTests.swift
//  War Card GameTests
//
//  Created by Robert Palmer on 2/12/26.
//

import Testing
import Foundation
@testable import War_Card_Game

@MainActor
struct War_Card_Game_PlayerTests {

    @Test
    func playerStartsWithCorrectCardCount() async throws {
        let cards = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king)
        ]

        let player = Player(cards: cards)

        #expect(player.cardCount == 2)
        #expect(player.isEmpty == false)
    }

    @Test
    func drawCardRemovesTopCard() async throws {
        var player = Player(cards: [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king)
        ])

        let drawn = player.drawCard()

        #expect(drawn?.rank == .ace)
        #expect(player.cardCount == 1)
    }

    @Test
    func drawCardReturnsNilWhenEmpty() async throws {
        var player = Player()

        let drawn = player.drawCard()

        #expect(drawn == nil)
        #expect(player.isEmpty == true)
    }

    @Test
    func receiveCardsAddsToBottomInOrder() async throws {
        var player = Player(cards: [
            Card(suit: .spades, rank: .ace)
        ])

        let wonCards = [
            Card(suit: .hearts, rank: .king),
            Card(suit: .diamonds, rank: .queen)
        ]

        player.receiveCards(wonCards)

        #expect(player.cardCount == 3)

        #expect(player.drawCard()?.rank == .ace)
        #expect(player.drawCard()?.rank == .king)
        #expect(player.drawCard()?.rank == .queen)
    }

    @Test
    func receiveSingleCardAppendsToBottom() async throws {
        var player = Player(cards: [
            Card(suit: .spades, rank: .ace)
        ])

        player.receiveCards([Card(suit: .hearts, rank: .king)])

        #expect(player.cardCount == 2)
        #expect(player.drawCard()?.rank == .ace)
        #expect(player.drawCard()?.rank == .king)
    }
}

