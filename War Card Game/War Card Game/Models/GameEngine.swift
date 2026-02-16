//
//  GameEngine.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//


import Foundation
<<<<<<< Updated upstream
=======

enum TurnResult {
    case player1Win(card1: Card, card2: Card)
    case player2Win(card1: Card, card2: Card)
    case war(initialCard1: Card, initialCard2: Card, winner: Player?)
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

    private(set) var state: GameState = .idle
    var player1: Player
    var player2: Player
    var deck: Deck
    var battlePile: [Card]
    
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

        precondition(handOne.count + handTwo.count == 52,
                     "Invalid deck size during dealing")

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
            return .player1Win(card1: card1, card2: card2)
        } else if card2.rank > card1.rank {
            player2.receiveCards(battlePile)
            battlePile.removeAll()
            return .player2Win(card1: card1, card2: card2)
        } else {
            // Tie detected — automatically resolve war internally
            state = .war
            let warWinner = handleWar()

            // If war caused the game to finish, signal final state clearly
            if case .finished = state {
                return .war(initialCard1: card1,
                            initialCard2: card2,
                            winner: warWinner)
            }

            return .war(initialCard1: card1,
                        initialCard2: card2,
                        winner: warWinner)
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
                return winner
            }

            if player2.cardCount < 4 {
                let winner = player1
                winner.receiveCards(battlePile)
                battlePile.removeAll()
                state = .finished(winner: winner)
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
                return winner
            }

            battlePile.append(warCard1)
            battlePile.append(warCard2)

            // Compare war cards
            if warCard1.rank > warCard2.rank {
                player1.receiveCards(battlePile)
                battlePile.removeAll()
                state = .active
                return player1
            } else if warCard2.rank > warCard1.rank {
                player2.receiveCards(battlePile)
                battlePile.removeAll()
                state = .active
                return player2
            }

            // If tie again, continue loop
        }

        // Failsafe: force resolution if max depth reached
        let winner = player1.cardCount >= player2.cardCount ? player1 : player2
        winner.receiveCards(battlePile)
        battlePile.removeAll()
        state = .active
        return winner
    }
    
    func startGame() {
        state = .active
        battlePile.removeAll()
        shuffleDeck()
        dealCards()
    }
}
>>>>>>> Stashed changes
