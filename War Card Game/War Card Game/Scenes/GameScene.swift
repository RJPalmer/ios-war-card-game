//
//  GameScene.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/3/26.
//

import SpriteKit

final class GameScene: SKScene {

    private let viewModel = GameViewModel()
    private var currentPlayerCard: Card?
    private var currentCPUCard: Card?
    private enum SceneState {
        case idle
        case animating
        case warDealing
        case warResolving
        case gameOver
    }

    private var sceneState: SceneState = .idle

    // MARK: - Nodes

    private let cpuCardNode = SKSpriteNode(imageNamed: "card_back")
    private let playerCardNode = SKSpriteNode(imageNamed: "card_back")

    private let resultLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let cpuCountLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")
    private let playerCountLabel = SKLabelNode(fontNamed: "AvenirNext-Regular")

    private let playButton = SKShapeNode(rectOf: CGSize(width: 160, height: 50), cornerRadius: 12)
    private let playButtonLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")

    private var hasCreatedNodes = false

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.05, green: 0.25, blue: 0.15, alpha: 1)
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        if !hasCreatedNodes {
            createNodes()
            hasCreatedNodes = true
        }

        layoutNodes()
        updateUI()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layoutNodes()
    }

    // MARK: - Node Creation (Called Once)

    private func createNodes() {

        // CPU Card
        cpuCardNode.setScale(0.65)
        addChild(cpuCardNode)

        cpuCountLabel.fontSize = 16
        cpuCountLabel.fontColor = .white
        cpuCountLabel.verticalAlignmentMode = .center
        cpuCountLabel.horizontalAlignmentMode = .center
        addChild(cpuCountLabel)

        // Player Card
        playerCardNode.setScale(0.65)
        addChild(playerCardNode)

        playerCountLabel.fontSize = 16
        playerCountLabel.fontColor = .white
        playerCountLabel.verticalAlignmentMode = .center
        playerCountLabel.horizontalAlignmentMode = .center
        addChild(playerCountLabel)

        // Result Label
        resultLabel.fontSize = 20
        resultLabel.fontColor = .white
        resultLabel.verticalAlignmentMode = .center
        resultLabel.horizontalAlignmentMode = .center
        resultLabel.text = ""
        addChild(resultLabel)

        // Play Button
        playButton.fillColor = .white
        playButton.name = "playButton"
        addChild(playButton)

        playButtonLabel.text = "Play Turn"
        playButtonLabel.fontSize = 18
        playButtonLabel.fontColor = .black
        playButtonLabel.verticalAlignmentMode = .center
        playButtonLabel.horizontalAlignmentMode = .center
        playButtonLabel.position = .zero
        playButton.addChild(playButtonLabel)
    }

    // MARK: - Layout (Called On Resize)

    private func layoutNodes() {

        // Layout using proportional positioning (anchorPoint = 0.5,0.5)

        let verticalSpacing = playerCardNode.size.height * 0.75

        // CPU Area (Top Third)
        cpuCardNode.position = CGPoint(x: 0, y: size.height * 0.30)
        cpuCountLabel.position = CGPoint(x: 0, y: cpuCardNode.position.y - verticalSpacing)

        // Battle Result Area (Center)
        resultLabel.position = CGPoint(x: 0, y: 0)

        // Player Area (Bottom Third)
        playerCardNode.position = CGPoint(x: 0, y: -size.height * 0.25)
        playerCountLabel.position = CGPoint(x: 0, y: playerCardNode.position.y + verticalSpacing)

        // Play Button (Near Bottom)
        playButton.position = CGPoint(x: 0, y: -size.height * 0.45)
    }

    // MARK: - UI Updates

    private func updateUI() {
        // Model-driven rendering using snapshot


        if let playerCard = viewModel.snapshot.playerCard {
            if currentPlayerCard != playerCard {

                let texture = CardTextureManager.shared.texture(
                    for: playerCard.rank,
                    suit: playerCard.suit
                )

                playerCardNode.texture = texture

                #if DEBUG
                // Remove previous debug label
                playerCardNode.childNode(withName: "debugLabel")?.removeFromParent()

                // Add updated label
                let label = CardTextureManager.shared.debugLabel(
                    for: playerCard.rank,
                    suit: playerCard.suit
                )
                label.name = "debugLabel"
                playerCardNode.addChild(label)
                #endif

                currentPlayerCard = playerCard
            }
        }
        if let cpuCard = viewModel.snapshot.cpuCard {
            if currentCPUCard != cpuCard {
                let texture = CardTextureManager.shared.texture(for: cpuCard.rank,
                                                                suit: cpuCard.suit)
                cpuCardNode.texture = texture
                currentCPUCard = cpuCard
            }
        } else {
            cpuCardNode.texture = SKTexture(imageNamed: "card_back")
            currentCPUCard = nil
        }

        resultLabel.text = "" // optional: remove UI-dependent strings

        playerCountLabel.text = "Player Cards: \(viewModel.snapshot.playerCardCount)"
        cpuCountLabel.text = "CPU Cards: \(viewModel.snapshot.cpuCardCount)"

        syncSceneStateWithSnapshot()

        updatePlayButtonState()
    }

    private func updatePlayButtonState() {
        if sceneState == .gameOver {
            playButton.fillColor = .gray
        } else {
            playButton.fillColor = .white
        }
    }

    /// Keeps the SpriteKit scene state synchronized with the ViewModel snapshot
    /// while avoiding interference with active animations.
    private func syncSceneStateWithSnapshot() {

        // Never override state while animations are running
        if sceneState == .animating || sceneState == .warDealing || sceneState == .warResolving {
            return
        }

        switch viewModel.snapshot.state {
        case .finished:
            sceneState = .gameOver
        default:
            sceneState = .idle
        }
    }

    // MARK: - Turn Animation

    private func runTurnAnimation() {
        // Production safety: disable input while animations run
        isUserInteractionEnabled = false
        sceneState = .animating

        let flipOutPlayer = SKAction.scaleX(to: 0, duration: 0.12)
        let flipOutCPU = SKAction.scaleX(to: 0, duration: 0.12)

        playerCardNode.run(flipOutPlayer)
        cpuCardNode.run(flipOutCPU)

        run(SKAction.wait(forDuration: 0.13)) { [weak self] in
            guard let self = self else { return }

            self.viewModel.playTurn()
            self.updateUI()

            let flipInPlayer = SKAction.scaleX(to: 1, duration: 0.12)
            let flipInCPU = SKAction.scaleX(to: 1, duration: 0.12)

            self.playerCardNode.run(flipInPlayer)
            self.cpuCardNode.run(flipInCPU)


            if self.viewModel.snapshot.state == .war {
                self.run(SKAction.wait(forDuration: 0.25)) {
                    self.runWarAnimation()
                }
            } else {
                self.run(SKAction.wait(forDuration: 0.2)) {
                    self.finishTurn()
                }
            }
        }
    }

    private func runWarAnimation() {
        sceneState = .warDealing

        let centerPosition = CGPoint(x: 0, y: 0)

        let movePlayer = SKAction.move(to: centerPosition.applying(CGAffineTransform(translationX: -20, y: 0)), duration: 0.2)
        let moveCPU = SKAction.move(to: centerPosition.applying(CGAffineTransform(translationX: 20, y: 0)), duration: 0.2)

        let scaleDown = SKAction.scale(to: 0.55, duration: 0.2)

        playerCardNode.run(SKAction.group([movePlayer, scaleDown]))
        cpuCardNode.run(SKAction.group([moveCPU, scaleDown]))

        run(SKAction.wait(forDuration: 0.35)) { [weak self] in
            guard let self = self else { return }
            self.resolveWarBattle()
        }
    }

    private func resolveWarBattle() {
        sceneState = .warResolving

        let flipOutPlayer = SKAction.scaleX(to: 0, duration: 0.12)
        let flipOutCPU = SKAction.scaleX(to: 0, duration: 0.12)

        playerCardNode.run(flipOutPlayer)
        cpuCardNode.run(flipOutCPU)

        run(SKAction.wait(forDuration: 0.13)) { [weak self] in
            guard let self = self else { return }

            self.viewModel.playTurn()
            self.updateUI()

            let flipInPlayer = SKAction.scaleX(to: 1, duration: 0.12)
            let flipInCPU = SKAction.scaleX(to: 1, duration: 0.12)

            self.playerCardNode.run(flipInPlayer)
            self.cpuCardNode.run(flipInCPU)

            self.run(SKAction.wait(forDuration: 0.25)) {
                self.resetCardPositions()
                self.finishTurn()
            }
        }
    }

    private func resetCardPositions() {
        let resetPlayer = SKAction.move(to: CGPoint(x: 0, y: -size.height * 0.25), duration: 0.2)
        let resetCPU = SKAction.move(to: CGPoint(x: 0, y: size.height * 0.30), duration: 0.2)
        let scaleUp = SKAction.scale(to: 0.65, duration: 0.2)

        playerCardNode.run(SKAction.group([resetPlayer, scaleUp]))
        cpuCardNode.run(SKAction.group([resetCPU, scaleUp]))
    }

    private func finishTurn() {

        // Animation is complete
        sceneState = .idle

        // Now sync with model state
        syncSceneStateWithSnapshot()

        // Re-enable input
        isUserInteractionEnabled = true
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("SceneState:", sceneState)
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        guard playButton.contains(location),
              sceneState == .idle else { return }

        runTurnAnimation()
    }
}
 
