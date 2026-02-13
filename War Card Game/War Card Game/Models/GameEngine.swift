//
//  GameEngine.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/10/26.
//

import Foundation

class GameEngine {
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
    
    func playTurn() {
        // Ensure both players have at least one card
        guard let card1 = player1.drawCard(),
              let card2 = player2.drawCard() else {
            return
        }

        // Add played cards to the battle pile
        battlePile.append(card1)
        battlePile.append(card2)

        // Compare ranks directly (since Rank is Comparable)
        if card1.rank > card2.rank {
            player1.receiveCards(battlePile)
            battlePile.removeAll()
        } else if card2.rank > card1.rank {
            player2.receiveCards(battlePile)
            battlePile.removeAll()
        } else {
            // Tie scenario — initiate war
            handleWar()
        }
    }
    
    func handleWar() {
        // Handle the war scenario when players tie
        // Each player places additional cards face down and one card face up
        // Compare face-up cards to determine winner
        // Winner takes all cards in the battle pile
        // If tie continues, repeat war
    }
    
    func checkGameOver() -> Bool {
        // Check if either player has no cards left
        // Return true if game is over, else false
        return false
    }
    
    func startGame() {
        // Start the game by shuffling the deck and dealing cards to players
        shuffleDeck()
        dealCards()
    }
}
