//
//  GameEngine.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

// Struct-based TurnResult now carries all necessary info for the ViewModel snapshot.
// Storing the engine state in TurnResult ensures the ViewModel snapshot can access it directly,
// making snapshot-driven UI fully deterministic.
struct TurnResult {
    let playerCardDrawn: Card
    let cpuCardDrawn: Card
    let playerCardCount: Int
    let cpuCardCount: Int
    let winner: Player? // nil if war
    let isWar: Bool
    let state: GameEngine.GameState // <--- new stored property capturing engine state
}

class GameEngine {
    
    enum GameState: Equatable {
        case idle
        case active
        case war
        case finished(winner: Player)

        static func == (lhs: GameState, rhs: GameState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle),
                 (.active, .active),
                 (.war, .war):
                return true
            case (.finished(let lWinner), .finished(let rWinner)):
                return lWinner.name == rWinner.name
            default:
                return false
            }
        }
    }

    #if DEBUG
    private func logGameStateChange(from old: GameState, to new: GameState) {
        guard old != new else { return }
        print("GameState changed: \(old) -> \(new)")
    }
    #endif

    #if DEBUG
    private func logBattleResult(playerCard: Card, cpuCard: Card, winner: Player?, isWar: Bool) {
        let p = "P1: \(playerCard.rank.displayName) of \(playerCard.suit.displayName)"
        let c = "CPU: \(cpuCard.rank.displayName) of \(cpuCard.suit.displayName)"
        if isWar {
            if let winner = winner {
                print("Battle (WAR) => \(p) vs \(c) -> Winner: \(winner.name)")
            } else {
                print("Battle (WAR) => \(p) vs \(c) -> Continuing war (tie)")
            }
        } else {
            if let winner = winner {
                print("Battle => \(p) vs \(c) -> Winner: \(winner.name)")
            } else {
                print("Battle => \(p) vs \(c) -> Tie")
            }
        }
    }
    #endif

    private(set) var state: GameState = .idle {
        didSet {
            #if DEBUG
            logGameStateChange(from: oldValue, to: state)
            #endif
        }
    }
    var player1: Player
    var player2: Player
    var deck: Deck
    var battlePile: [Card]
    // Stores the last turn's result; optional until the first turn is played.
    private(set) var currentTurnResult: TurnResult?
    
    init() {
        // Initialize players, deck, and battle pile
        player1 = Player(name: "Player 1")
        player2 = Player(name: "Player 2")
        deck = Deck()
        battlePile = []
        
        // Additional initialization logic here
    }
    
    func shuffleDeck() {
        // Shuffle the deck of cards before dealing
        // Example: deck.shuffle()
        deck.shuffle()
    }
    
    /// Deals cards evenly to both players from the current deck.
    ///
    /// This method assumes the deck has already been shuffled (see `shuffleDeck()`).
    /// It alternates dealing one card at a time to `player1` and `player2` until the
    /// deck is exhausted or no more cards can be dealt.
    ///
    /// - Important: Calling this more than once without resetting the deck and players
    ///   may result in duplicated or inconsistent state. Ensure you start from a fresh
    ///   `Deck` and empty player hands when starting a new game.
    ///
    /// - Precondition: `deck` contains a standard set of cards ready to be dealt.
    /// - Postcondition: The deck is emptied (or reduced) and both players have been
    ///   assigned cards as evenly as possible (the difference in counts is at most 1).
    ///
    /// - Note: If the deck has an odd number of cards, `player1` will receive one more card.
    /// - SeeAlso: `shuffleDeck()`, `startGame()`
    func dealCards() {
        let (handOne, handTwo) = deck.dealEvenly()

        if handOne.count + handTwo.count != 52 {
            print("Warning: Deck size is not 52 during dealing")
        }

        player1.setCards(handOne)
        player2.setCards(handTwo)
    }
    
    func playTurn() -> TurnResult? {
        guard state == .active else {
            return nil
        }

        if player1.cardCount == 0 {
            state = .finished(winner: player2)
            return nil
        }

        if player2.cardCount == 0 {
            state = .finished(winner: player1)
            return nil
        }

        guard let card1 = player1.drawCard(),
              let card2 = player2.drawCard() else {
            return nil
        }

        // Add played cards to the battle pile
        battlePile.append(card1)
        battlePile.append(card2)

        // Compare ranks directly (Rank conforms to Comparable)
        if card1.rank > card2.rank {
            player1.receiveCards(battlePile)
            battlePile.removeAll()
            let result = TurnResult(
                playerCardDrawn: card1,
                cpuCardDrawn: card2,
                playerCardCount: player1.cardCount,
                cpuCardCount: player2.cardCount,
                winner: player1,
                isWar: false,
                state: self.state // store engine state
            )
            currentTurnResult = result
            #if DEBUG
            logBattleResult(playerCard: card1, cpuCard: card2, winner: player1, isWar: false)
            #endif
            return result
        } else if card2.rank > card1.rank {
            player2.receiveCards(battlePile)
            battlePile.removeAll()
            let result = TurnResult(
                playerCardDrawn: card1,
                cpuCardDrawn: card2,
                playerCardCount: player1.cardCount,
                cpuCardCount: player2.cardCount,
                winner: player2,
                isWar: false,
                state: self.state
            )
            currentTurnResult = result
            #if DEBUG
            logBattleResult(playerCard: card1, cpuCard: card2, winner: player2, isWar: false)
            #endif
            return result
        } else {
            // Tie detected — automatically resolve war internally
            state = .war
            let warWinner = handleWar()

            // If war caused the game to finish, signal final state clearly
            let result = TurnResult(
                playerCardDrawn: card1,
                cpuCardDrawn: card2,
                playerCardCount: player1.cardCount,
                cpuCardCount: player2.cardCount,
                winner: warWinner,
                isWar: true,
                state: self.state
            )
            currentTurnResult = result
            #if DEBUG
            print("WAR triggered by tie: P1 \(card1.displayName) vs CPU \(card2.displayName)")
            if let warWinner = warWinner {
                print("WAR decided; awarding pile to \(warWinner.name)")
            } else {
                print("WAR sequence ended without a winner (unexpected)")
            }
            #endif
            return result
        }
    }
    
    func handleWar() -> Player? {
        state = .war

        var warDepth = 0
        let maxWarDepth = 100

        while warDepth < maxWarDepth {
            warDepth += 1

            // If a player cannot continue war, award battlePile and finish game
            if player1.cardCount < 4 {
                let winner = player2
                winner.receiveCards(battlePile)
                battlePile.removeAll()
                state = .finished(winner: winner)
                #if DEBUG
                print("WAR ended early: opponent cannot continue; awarding pile to \(winner.name)")
                #endif
                return winner
            }

            if player2.cardCount < 4 {
                let winner = player1
                winner.receiveCards(battlePile)
                battlePile.removeAll()
                state = .finished(winner: winner)
                #if DEBUG
                print("WAR ended early: opponent cannot continue; awarding pile to \(winner.name)")
                #endif
                return winner
            }

            // Three face-down cards
            for _ in 0..<3 {
                if let down1 = player1.drawCard() {
                    battlePile.append(down1)
                }
                if let down2 = player2.drawCard() {
                    battlePile.append(down2)
                }
            }

            // One face-up card
            guard let warCard1 = player1.drawCard(),
                  let warCard2 = player2.drawCard() else {

                let winner = player1.cardCount > 0 ? player1 : player2
                winner.receiveCards(battlePile)
                battlePile.removeAll()
                state = .finished(winner: winner)
                #if DEBUG
                print("WAR draw failure: awarding pile to \(winner.name)")
                #endif
                return winner
            }

            battlePile.append(warCard1)
            battlePile.append(warCard2)

            // Compare war cards
            if warCard1.rank > warCard2.rank {
                player1.receiveCards(battlePile)
                battlePile.removeAll()
                state = .active
                #if DEBUG
                print("WAR decided by upcards: P1 \(warCard1.rank.displayName) vs CPU \(warCard2.rank.displayName) -> Winner: \(player1.name)")
                #endif
                return player1
            } else if warCard2.rank > warCard1.rank {
                player2.receiveCards(battlePile)
                battlePile.removeAll()
                state = .active
                #if DEBUG
                print("WAR decided by upcards: P1 \(warCard1.rank.displayName) vs CPU \(warCard2.rank.displayName) -> Winner: \(player2.name)")
                #endif
                return player2
            }

            // If tie again, continue loop
        }

        // Failsafe: force resolution if max depth reached
        let winner = player1.cardCount >= player2.cardCount ? player1 : player2
        winner.receiveCards(battlePile)
        battlePile.removeAll()
        state = .active
        #if DEBUG
        print("War failsafe: awarding pile to \(winner.name) (higher remaining count)")
        #endif
        return winner
    }
    
    func startGame() {
        restartGame()
    }

    /// Fully resets the game to a clean initial state.
    /// This method reinitializes all core components to avoid any leftover state.
    func restartGame() {
        // Reset core state
        state = .idle
        currentTurnResult = nil
        battlePile.removeAll()

        // Reinitialize engine components (clean state, no shared references)
        player1 = Player(name: "Player 1")
        player2 = Player(name: "Player 2")
        deck = Deck()

        // Start fresh game setup
        shuffleDeck()
        dealCards()

        // Transition to active state after setup
        state = .active
    }
}

