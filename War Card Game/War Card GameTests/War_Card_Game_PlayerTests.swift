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
    func playerStartsEmptyByDefault() async throws {
        let player = Player()
        #expect(player.cardCount == 0)
        #expect(player.isEmpty == true)
        #expect(player.drawCard() == nil)
    }

    @Test
    func preservesOrderAcrossMultipleCards() async throws {
        let cards = [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king),
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .clubs, rank: .jack),
        ]
        let player = Player(cards: cards)

        #expect(player.cardCount == 4)
        #expect(player.drawCard()?.rank == .ace)
        #expect(player.drawCard()?.rank == .king)
        #expect(player.drawCard()?.rank == .queen)
        #expect(player.drawCard()?.rank == .jack)
        #expect(player.drawCard() == nil)
        #expect(player.isEmpty == true)
    }

    @Test
    func interleavedReceivesAndDrawsMaintainFIFO() async throws {
        var player = Player(cards: [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king)
        ])

        // Draw one (top)
        #expect(player.drawCard()?.rank == .ace) // remaining: king

        // Receive two to bottom
        player.receiveCards([
            Card(suit: .diamonds, rank: .queen),
            Card(suit: .clubs, rank: .jack)
        ])
        #expect(player.cardCount == 3)

        // Draw sequence should be: king, queen, jack
        #expect(player.drawCard()?.rank == .king)
        #expect(player.drawCard()?.rank == .queen)
        #expect(player.drawCard()?.rank == .jack)
        #expect(player.isEmpty == true)
    }

    @Test
    func receivingEmptyArrayDoesNotChangeState() async throws {
        let player = Player(cards: [
            Card(suit: .spades, rank: .ace)
        ])
        player.receiveCards([])
        #expect(player.cardCount == 1)
        #expect(player.drawCard()?.rank == .ace)
        #expect(player.drawCard() == nil)
    }

    @Test
    func refillAfterEmptyWorks() async throws {
        let player = Player(cards: [
            Card(suit: .spades, rank: .ace)
        ])
        _ = player.drawCard()
        #expect(player.isEmpty == true)

        let newCards = [
            Card(suit: .hearts, rank: .two),
            Card(suit: .hearts, rank: .three)
        ]
        player.receiveCards(newCards)

        #expect(player.isEmpty == false)
        #expect(player.cardCount == 2)
        #expect(player.drawCard()?.rank == .two)
        #expect(player.drawCard()?.rank == .three)
    }

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
        let player = Player(cards: [
            Card(suit: .spades, rank: .ace),
            Card(suit: .hearts, rank: .king)
        ])

        let drawn = player.drawCard()

        #expect(drawn?.rank == .ace)
        #expect(player.cardCount == 1)
    }

    @Test
    func drawCardReturnsNilWhenEmpty() async throws {
        let player = Player()

        let drawn = player.drawCard()

        #expect(drawn == nil)
        #expect(player.isEmpty == true)
    }

    @Test
    func receiveCardsAddsToBottomInOrder() async throws {
        let player = Player(cards: [
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
        let player = Player(cards: [
            Card(suit: .spades, rank: .ace)
        ])

        player.receiveCards([Card(suit: .hearts, rank: .king)])

        #expect(player.cardCount == 2)
        #expect(player.drawCard()?.rank == .ace)
        #expect(player.drawCard()?.rank == .king)
    }
}

