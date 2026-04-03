//
//  GameViewModel.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/17/26.
//

import Foundation

final class GameViewModel {

    struct TurnSnapshot {
        let playerCard: Card?
        let cpuCard: Card?
        let playerCardCount: Int
        let cpuCardCount: Int
        let state: GameEngine.GameState
        let isWar: Bool
        let winnerName: String?
    }

    private let engine: GameEngine
    private(set) var snapshot: TurnSnapshot

    var isGameOver: Bool {
        if case .finished = snapshot.state { return true }
        return false
    }

    init(engine: GameEngine = GameEngine()) {
        self.engine = engine
        engine.restartGame()
        snapshot = GameViewModel.makeSnapshot(from: engine)
    }

    @discardableResult
    func playTurn() -> TurnSnapshot {
        guard !isGameOver else { return snapshot }

        let _ = engine.playTurn()
        snapshot = GameViewModel.makeSnapshot(from: engine)
        return snapshot
    }

    /// Resets the game by delegating to the engine and rebuilding the snapshot
    func restartGame() {
        engine.restartGame()
        snapshot = GameViewModel.makeSnapshot(from: engine)
    }

    private static func makeSnapshot(from engine: GameEngine) -> TurnSnapshot {
        let currentTurn = engine.currentTurnResult

        return TurnSnapshot(
            playerCard: currentTurn?.playerCardDrawn,
            cpuCard: currentTurn?.cpuCardDrawn,
            playerCardCount: currentTurn?.playerCardCount ?? 0,
            cpuCardCount: currentTurn?.cpuCardCount ?? 0,
            state: currentTurn?.state ?? .idle,
            isWar: currentTurn?.isWar ?? false,
            winnerName: currentTurn?.winner?.name
        )
    }
}
