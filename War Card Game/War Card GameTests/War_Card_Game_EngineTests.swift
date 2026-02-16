//
//  War_Card_Game_EngineTests.swift
//  War Card GameTests
//
//  Created by Robert Palmer on 2/16/26.
//

import Testing
@testable import War_Card_Game

@MainActor
struct War_Card_Game_EngineTests {

    // MARK: - Initial State

    @Test
    func initialStateIsIdle() async throws {
        let engine = GameEngine()
        #expect(engine.state == .idle)
    }

    // MARK: - Game Start

    @Test
    func startGameDeals26CardsEach() async throws {
        let engine = GameEngine()
        engine.startGame()

        #expect(engine.player1.cardCount == 26)
        #expect(engine.player2.cardCount == 26)
        #expect(engine.player1.cardCount + engine.player2.cardCount == 52)
        #expect(engine.state == .active)
    }

    // MARK: - Normal Turn Resolution

    @Test
    func playTurnResolvesNormalWin() async throws {
        let engine = GameEngine()

        let highCard = Card(suit: .hearts, rank: .ace)
        let lowCard = Card(suit: .clubs, rank: .two)

        engine.startGame()
        engine.player1.setCards([highCard])
        engine.player2.setCards([lowCard])

        let result = engine.playTurn()

        if case .player1Win(let c1, let c2)? = result {
            #expect(c1.rank == .ace)
            #expect(c2.rank == .two)
        } else {
            Issue.record("Expected player1Win result")
        }

        #expect(engine.player1.cardCount == 2)
        #expect(engine.player2.cardCount == 0)
    }

    // MARK: - War Resolution

    @Test
    func playTurnResolvesWarAutomatically() async throws {
        let engine = GameEngine()

        let tie1 = Card(suit: .hearts, rank: .five)
        let tie2 = Card(suit: .clubs, rank: .five)

        let warCards1 = [
            tie1,
            Card(suit: .hearts, rank: .three),
            Card(suit: .hearts, rank: .four),
            Card(suit: .hearts, rank: .six),
            Card(suit: .hearts, rank: .king)
        ]

        let warCards2 = [
            tie2,
            Card(suit: .clubs, rank: .three),
            Card(suit: .clubs, rank: .four),
            Card(suit: .clubs, rank: .six),
            Card(suit: .clubs, rank: .queen)
        ]

         engine.startGame()
         engine.player1.setCards(warCards1)
        engine.player2.setCards(warCards2)

        let result =  engine.playTurn()

        if case .war(_, _, let winner)? = result {
            #expect(winner?.name == engine.player1.name)
        } else {
            Issue.record("Expected war result")
        }

        #expect(engine.state == .active)
    }

    // MARK: - Game Over

    @Test
    func gameFinishesWhenPlayerRunsOutOfCards() async throws {
        let engine = GameEngine()

        let highCard = Card(suit: .hearts, rank: .ace)

         engine.startGame()
         engine.player1.setCards([highCard])
         engine.player2.setCards([])

        _ =  engine.playTurn()

        if case .finished(let winner) = engine.state {
            #expect(winner.name == engine.player1.name)
        } else {
            Issue.record("Expected finished state")
        }
    }

    // MARK: - Card Integrity

    @Test
    func totalCardsRemain52AfterStart() async throws {
        let engine = GameEngine()
         engine.startGame()

        let total = engine.player1.cardCount + engine.player2.cardCount
        #expect(total == 52)
    }
}

