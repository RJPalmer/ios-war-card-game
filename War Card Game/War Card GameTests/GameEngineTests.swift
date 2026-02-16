//
//  GameEngineTests.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/15/26.
//


//
//  GameEngineTests.swift
//  War Card GameTests
//
//  Created by Robert Palmer on 2/13/26.
//

import XCTest
@testable import War_Card_Game

final class GameEngineTests: XCTestCase {

    var engine: GameEngine!

    override func setUp() {
        super.setUp()
        engine = GameEngine()
    }

    override func tearDown() {
        engine = nil
        super.tearDown()
    }

    // MARK: - Initialization

    func testInitialStateIsIdle() {
        XCTAssertEqual(engine.state, .idle)
    }

    // MARK: - Game Start

    func testStartGameDeals26CardsToEachPlayer() {
        engine.startGame()

        XCTAssertEqual(engine.player1.cardCount, 26)
        XCTAssertEqual(engine.player2.cardCount, 26)
        XCTAssertEqual(engine.player1.cardCount + engine.player2.cardCount, 52)
    }

    // MARK: - Turn Resolution

    func testPlayTurnResolvesNormalWin() {
        // Arrange deterministic hands
        let highCard = Card(rank: .ace, suit: .hearts)
        let lowCard = Card(rank: .two, suit: .clubs)

        engine.player1.setCards([highCard])
        engine.player2.setCards([lowCard])
        engine.state = .active

        // Act
        let result = engine.playTurn()

        // Assert
        switch result {
        case .player1Win(let c1, let c2):
            XCTAssertEqual(c1.rank, .ace)
            XCTAssertEqual(c2.rank, .two)
        default:
            XCTFail("Expected player1Win")
        }

        XCTAssertEqual(engine.player1.cardCount, 2)
        XCTAssertEqual(engine.player2.cardCount, 0)
    }

    // MARK: - War Resolution

    func testPlayTurnResolvesWarAutomatically() {
        let tie1 = Card(rank: .five, suit: .hearts)
        let tie2 = Card(rank: .five, suit: .clubs)

        // Enough cards for war resolution
        let warCards1 = [
            tie1,
            Card(rank: .three, suit: .hearts),
            Card(rank: .four, suit: .hearts),
            Card(rank: .six, suit: .hearts),
            Card(rank: .king, suit: .hearts) // winning war card
        ]

        let warCards2 = [
            tie2,
            Card(rank: .three, suit: .clubs),
            Card(rank: .four, suit: .clubs),
            Card(rank: .six, suit: .clubs),
            Card(rank: .queen, suit: .clubs)
        ]

        engine.player1.setCards(warCards1)
        engine.player2.setCards(warCards2)
        engine.state = .active

        let result = engine.playTurn()

        switch result {
        case .war(_, _, let winner):
            XCTAssertNotNil(winner)
            XCTAssertEqual(winner?.name, "Player 1")
        default:
            XCTFail("Expected war result")
        }

        XCTAssertEqual(engine.state, .active)
    }

    // MARK: - Game Over

    func testGameFinishesWhenPlayerRunsOutOfCards() {
        let highCard = Card(suit: .hearts, rank: .ace)

        engine.player1.setCards([highCard])
        engine.player2.setCards([])
        engine.state = .active

        _ = engine.playTurn()

        switch engine.state {
        case .finished(let winner):
            XCTAssertEqual(winner.name, "Player 1")
        default:
            XCTFail("Expected game to be finished")
        }
    }

    // MARK: - Total Card Integrity

    func testTotalCardsAlwaysEqual52AfterStart() {
        engine.startGame()
        let total = engine.player1.cardCount + engine.player2.cardCount

        XCTAssertEqual(total, 52)
    }
}
