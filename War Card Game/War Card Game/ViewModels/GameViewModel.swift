//
//  GameViewModel.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/17/26.
//

import Foundation

final class GameViewModel {

    private let engine = GameEngine()
    var playerCardImageName: String?
    var cpuCardImageName: String?
    var playerCardCount: Int = 0
    var cpuCardCount: Int = 0
    var resultText: String = ""
    var isGameOver: Bool {
        if case .finished = engine.state { return true }
        return false
    }

    init() {
        // Prepare and start the game according to GameEngine API
        engine.startGame()
        syncState()
    }

    func playTurn() {
        guard !isGameOver else { return }

        // Play a single turn according to GameEngine API
        _ = engine.playTurn()
        syncState()
    }

    private func syncState() {
        // Derive last played cards from the battle pile if available
        // Assuming the last two cards in battlePile correspond to the most recent flip
        if engine.battlePile.count >= 2 {
            let lastTwo = engine.battlePile.suffix(2)
            // Order assumption: player1 then player2
            let cards = Array(lastTwo)
            playerCardImageName = cards.first?.suit.rawValue
            cpuCardImageName = cards.last?.suit.rawValue
        } else {
            playerCardImageName = nil
            cpuCardImageName = nil
        }

        // Update card counts from players
        playerCardCount = engine.player1.cardCount
        cpuCardCount = engine.player2.cardCount

        // Update result text based on state
        switch engine.state {
        case .idle:
            resultText = ""
        case .active:
            resultText = ""
        case .war:
            resultText = "WAR!"
        case .finished(let winner):
            resultText = "Winner: \(winner.name)"
        }
    }
}
