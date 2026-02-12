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
    }
    
    func dealCards() {
        // Shuffle the deck and deal cards evenly to both players
        // Example: alternate dealing cards until deck is empty
    }
    
    func playTurn() {
        // Each player plays a card
        // Compare the cards and determine the winner of the turn
        // Winner takes the cards in the battle pile
        // If tie, call handleWar()
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
