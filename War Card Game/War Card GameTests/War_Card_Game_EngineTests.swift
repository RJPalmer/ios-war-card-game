import Testing
@testable import War_Card_Game

@MainActor
struct War_Card_Game_EngineTests {

    // MARK: - Initial State

    @Test
    func initialStateIsIdle() async throws {
        let engine = GameEngine()
        #expect(engine.state == .idle)
        #expect(engine.player1.cardCount == 0)
        #expect(engine.player2.cardCount == 0)
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

    @Test
    func restartGameResetsStateAndCards() async throws {
        let engine = GameEngine()
        engine.startGame()
        _ = engine.playTurn()

        engine.restartGame()
        #expect(engine.state == .idle || engine.state == .active) // depending on restart impl
        #expect(engine.player1.cardCount + engine.player2.cardCount == 52)
    }

    // MARK: - Normal Turn Resolution

    @Test
    func playTurnResolvesNormalWin_Player1HighCard() async throws {
        let engine = GameEngine()
        engine.startGame()

        // Give P1 a high upcard and P2 a low upcard
        let highCard = Card(suit: .hearts, rank: .ace)
        let lowCard  = Card(suit: .clubs,  rank: .two)
        engine.player1.setCards([highCard])
        engine.player2.setCards([lowCard])

        let preTotal = engine.player1.cardCount + engine.player2.cardCount
        let result = engine.playTurn()

        // After a normal win, P1 should collect both upcards
        #expect(engine.player1.cardCount == 2)
        #expect(engine.player2.cardCount == 0)
        #expect(engine.player1.cardCount + engine.player2.cardCount == preTotal)

        // Engine should be either active or finished depending on implementation
        if case .finished(let winner) = engine.state {
            #expect(winner.name == engine.player1.name)
        } else {
            #expect(engine.state == .active)
        }

        // Result checks (if TurnResult exposes cards; otherwise skip)
        if let r = result {
            // If your TurnResult exposes cards drawn, assert them here
            // e.g., #expect(r.playerCardDrawn == highCard)
            //       #expect(r.cpuCardDrawn == lowCard)
        }
    }

    @Test
    func playTurnResolvesNormalWin_Player2HighCard() async throws {
        let engine = GameEngine()
        engine.startGame()

        let lowCard  = Card(suit: .hearts, rank: .two)
        let highCard = Card(suit: .clubs,  rank: .ace)
        engine.player1.setCards([lowCard])
        engine.player2.setCards([highCard])

        let preTotal = engine.player1.cardCount + engine.player2.cardCount
        _ = engine.playTurn()

        #expect(engine.player2.cardCount == 2)
        #expect(engine.player1.cardCount == 0)
        #expect(engine.player1.cardCount + engine.player2.cardCount == preTotal)

        if case .finished(let winner) = engine.state {
            #expect(winner.name == engine.player2.name)
        } else {
            #expect(engine.state == .active)
        }
    }

    // MARK: - War Resolution

    @Test
    func playTurnTriggersWarAndResolvesToWinner() async throws {
        let engine = GameEngine()
        engine.startGame()

        // Setup: first two cards tied; then provide enough cards to resolve
        let tie1 = Card(suit: .hearts, rank: .five)
        let tie2 = Card(suit: .clubs,  rank: .five)

        // War requires (n-1) down, last up; we'll provide 4 total per side
        let p1Cards = [
            tie1,                           // upcard tie
            Card(suit: .hearts, rank: .three), // face-down
            Card(suit: .hearts, rank: .four),  // face-down
            Card(suit: .hearts, rank: .six),   // face-down
            Card(suit: .hearts, rank: .king)   // upcard wins
        ]
        let p2Cards = [
            tie2,
            Card(suit: .clubs, rank: .three),
            Card(suit: .clubs, rank: .four),
            Card(suit: .clubs, rank: .six),
            Card(suit: .clubs, rank: .queen)   // upcard loses
        ]
        engine.player1.setCards(p1Cards)
        engine.player2.setCards(p2Cards)

        let preTotal = engine.player1.cardCount + engine.player2.cardCount
        let result = engine.playTurn()

        // After resolving war, P1 should have collected the pile
        #expect(engine.player1.cardCount > engine.player2.cardCount)
        #expect(engine.player1.cardCount + engine.player2.cardCount == preTotal)

        // Engine should generally remain active (unless war empties a player)
        #expect(engine.state == .active || {
            if case .finished = engine.state { return true }
            return false
        }())

        // If TurnResult exposes war info, assert it here
        if let r = result {
            // e.g., #expect(r.isWar == true)
            //       #expect(r.winner?.name == engine.player1.name)
        }
    }

    @Test
    func recursiveWarResolvesProperly() async throws {
        let engine = GameEngine()
        engine.startGame()

        // Setup two ties in a row, then resolve
        let tieA1 = Card(suit: .hearts, rank: .seven)
        let tieA2 = Card(suit: .clubs,  rank: .seven)

        let tieB1 = Card(suit: .hearts, rank: .nine)
        let tieB2 = Card(suit: .clubs,  rank: .nine)

        // Provide enough cards to support two wars and a final resolution
        // Simplified layout; exact counts depend on your handleWar rules
        let p1Cards: [Card] = [
            tieA1, // first tie
            // face-downs + upcard for first war
            .init(suit: .hearts, rank: .two),
            .init(suit: .hearts, rank: .three),
            .init(suit: .hearts, rank: .four),
            tieB1, // second tie
            // face-downs + final upcard
            .init(suit: .hearts, rank: .two),
            .init(suit: .hearts, rank: .three),
            .init(suit: .hearts, rank: .four),
            .init(suit: .hearts, rank: .king) // final win
        ]

        let p2Cards: [Card] = [
            tieA2,
            .init(suit: .clubs, rank: .two),
            .init(suit: .clubs, rank: .three),
            .init(suit: .clubs, rank: .four),
            tieB2,
            .init(suit: .clubs, rank: .two),
            .init(suit: .clubs, rank: .three),
            .init(suit: .clubs, rank: .four),
            .init(suit: .clubs, rank: .queen) // final lose
        ]

        engine.player1.setCards(p1Cards)
        engine.player2.setCards(p2Cards)

        let preTotal = engine.player1.cardCount + engine.player2.cardCount
        _ = engine.playTurn()

        #expect(engine.player1.cardCount + engine.player2.cardCount == preTotal)
        #expect(engine.player1.cardCount > engine.player2.cardCount)
        #expect({
            // active or finished depending on if someone got emptied
            if case .finished = engine.state { return true }
            return engine.state == .active
        }())
    }

    @Test
    func warEndsIfAPlayerCannotPlaceRequiredCards() async throws {
        let engine = GameEngine()
        engine.startGame()

        // P2 cannot place enough war cards; P1 should win and game may finish
        let tieP1 = Card(suit: .hearts, rank: .eight)
        let tieP2 = Card(suit: .clubs,  rank: .eight)

        engine.player1.setCards([tieP1, .init(suit: .hearts, rank: .two), .init(suit: .hearts, rank: .three), .init(suit: .hearts, rank: .four), .init(suit: .hearts, rank: .ace)])
        engine.player2.setCards([tieP2]) // insufficient for war

        _ = engine.playTurn()

        // Engine should mark finished with P1 winner (or at least not remain in war)
        if case .finished(let winner) = engine.state {
            #expect(winner.name == engine.player1.name)
        } else {
            // If engine chooses to remain active but give all cards to P1, still OK
            #expect(engine.player1.cardCount > engine.player2.cardCount)
        }
    }

    // MARK: - Game Over

    @Test
    func gameFinishesWhenPlayerRunsOutOfCards() async throws {
        let engine = GameEngine()
        engine.startGame()

        let highCard = Card(suit: .hearts, rank: .ace)
        engine.player1.setCards([highCard])
        engine.player2.setCards([])

        _ = engine.playTurn()

        if case .finished(let winner) = engine.state {
            #expect(winner.name == engine.player1.name)
        } else {
            Issue.record("Expected finished state")
        }
    }

    @Test
    func gameFinishesAfterWarWhenLoserIsEmptied() async throws {
        let engine = GameEngine()
        engine.startGame()

        // Tie, then upcard empties P2
        let tie1 = Card(suit: .hearts, rank: .ten)
        let tie2 = Card(suit: .clubs,  rank: .ten)

        engine.player1.setCards([
            tie1, .init(suit: .hearts, rank: .two), .init(suit: .hearts, rank: .three), .init(suit: .hearts, rank: .four), .init(suit: .hearts, rank: .king)
        ])
        engine.player2.setCards([
            tie2 // P2 cannot complete war; should lose
        ])

        _ = engine.playTurn()

        if case .finished(let winner) = engine.state {
            #expect(winner.name == engine.player1.name)
        } else {
            Issue.record("Expected finished state after war")
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
