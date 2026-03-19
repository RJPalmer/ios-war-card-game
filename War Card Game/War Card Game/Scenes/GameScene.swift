//
//  GameScene.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/3/26.
//

import SpriteKit

final class GameScene: SKScene {

    // MARK: - War Animation Support
    private var warPlayerFaceDownNodes: [SKSpriteNode] = []
    private var warCPUFaceDownNodes: [SKSpriteNode] = []
    private var warPlayerFaceUpNode: SKSpriteNode?
    private var warCPUFaceUpNode: SKSpriteNode?

    private var warAllTempNodes: [SKNode] {
        var nodes: [SKNode] = []
        nodes.append(contentsOf: warPlayerFaceDownNodes)
        nodes.append(contentsOf: warCPUFaceDownNodes)
        if let n = warPlayerFaceUpNode { nodes.append(n) }
        if let n = warCPUFaceUpNode { nodes.append(n) }
        return nodes
    }

    private var warCenter: CGPoint { CGPoint(x: 0, y: 0) }
    private var warPlayerLaneY: CGFloat { -size.height * 0.05 }
    private var warCPULaneY: CGFloat { size.height * 0.05 }
    private let warCardScale: CGFloat = 0.5
    private let warCardSpacing: CGFloat = 16

    private func makeCardNode(texture: SKTexture, scale: CGFloat, z: CGFloat = 0) -> SKSpriteNode {
        let node = SKSpriteNode(texture: texture)
        node.size = CGSize(width: CardNode.defaultSize.width, height: CardNode.defaultSize.height)
        node.setScale(scale)
        node.zPosition = z
        return node
    }

    private func makeFaceDownNode(scale: CGFloat) -> SKSpriteNode {
        return makeCardNode(texture: SKTexture(imageNamed: "card_back"), scale: scale)
    }

    private func warPositions(isPlayer: Bool, count: Int) -> [CGPoint] {
        guard count > 0 else { return [] }
        let baseY = isPlayer ? warPlayerLaneY : warCPULaneY
        let totalWidth = CGFloat(max(count - 1, 0)) * warCardSpacing
        return (0..<count).map { i in
            let x = -totalWidth / 2 + CGFloat(i) * warCardSpacing
            return CGPoint(x: x, y: baseY)
        }
    }

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

    #if DEBUG
    private func logSceneStateChange(from old: SceneState, to new: SceneState) {
        guard old != new else { return }
        print("SceneState changed: \(old) -> \(new)")
    }
    #endif

    private var sceneState: SceneState = .idle {
        didSet {
            #if DEBUG
            logSceneStateChange(from: oldValue, to: sceneState)
            #endif
        }
    }

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
                
                #if DEBUG
                cpuCardNode.childNode(withName: "debugLabel")?.removeFromParent()
                
                //add updated label
                let label = CardTextureManager.shared.debugLabel(
                    for: cpuCard.rank,
                    suit: cpuCard.suit
                    )
                label.name = "debugLabel"
                cpuCardNode.addChild(label)
                #endif
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

        // Move main cards to lanes and shrink to make room
        let playerLanePos = CGPoint(x: -20, y: warPlayerLaneY)
        let cpuLanePos = CGPoint(x: 20, y: warCPULaneY)
        let movePlayer = SKAction.move(to: playerLanePos, duration: 0.2)
        let moveCPU = SKAction.move(to: cpuLanePos, duration: 0.2)
        let scaleDown = SKAction.scale(to: warCardScale, duration: 0.2)

        playerCardNode.run(SKAction.group([movePlayer, scaleDown]))
        cpuCardNode.run(SKAction.group([moveCPU, scaleDown]))

        run(SKAction.wait(forDuration: 0.25)) { [weak self] in
            guard let self = self else { return }
            self.dealWarCards()
        }
    }

    private func resolveWarBattle() {
        sceneState = .warResolving

        let flipOut = SKAction.scaleX(to: 0, duration: 0.12)
        warPlayerFaceUpNode?.run(flipOut)
        warCPUFaceUpNode?.run(flipOut)

        run(SKAction.wait(forDuration: 0.13)) { [weak self] in
            guard let self = self else { return }

            // Advance the model to reveal war upcards and determine winner
            self.viewModel.playTurn()
            self.updateUI()

            if let pCard = self.viewModel.snapshot.playerCard {
                let tex = CardTextureManager.shared.texture(for: pCard.rank, suit: pCard.suit)
                self.warPlayerFaceUpNode?.texture = tex
            }
            if let cCard = self.viewModel.snapshot.cpuCard {
                let tex = CardTextureManager.shared.texture(for: cCard.rank, suit: cCard.suit)
                self.warCPUFaceUpNode?.texture = tex
            }

            let flipIn = SKAction.scaleX(to: 1, duration: 0.12)
            self.warPlayerFaceUpNode?.run(flipIn)
            self.warCPUFaceUpNode?.run(flipIn)

            self.run(SKAction.wait(forDuration: 0.25)) {
                self.gatherWarPileAndAward()
            }
        }
    }

    private func dealWarCards() {
        // Determine how many cards each side can place according to n-1 down, last up rule
        let playerRemaining = viewModel.snapshot.playerCardCount
        let cpuRemaining = viewModel.snapshot.cpuCardCount
        let pN = max(min(4, playerRemaining), 0)
        let cN = max(min(4, cpuRemaining), 0)

        let playerPositions = warPositions(isPlayer: true, count: pN)
        let cpuPositions = warPositions(isPlayer: false, count: cN)

        // Player face-down cards
        if pN > 1 {
            for i in 0..<(pN - 1) {
                let node = makeFaceDownNode(scale: warCardScale)
                node.position = playerCardNode.position
                node.alpha = 0
                addChild(node)
                warPlayerFaceDownNodes.append(node)

                let delay = 0.06 * Double(i)
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.08),
                        SKAction.move(to: playerPositions[i], duration: 0.15)
                    ])
                ]))
            }
        }

        // CPU face-down cards
        if cN > 1 {
            for i in 0..<(cN - 1) {
                let node = makeFaceDownNode(scale: warCardScale)
                node.position = cpuCardNode.position
                node.alpha = 0
                addChild(node)
                warCPUFaceDownNodes.append(node)

                let delay = 0.06 * Double(i)
                node.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    SKAction.group([
                        SKAction.fadeIn(withDuration: 0.08),
                        SKAction.move(to: cpuPositions[i], duration: 0.15)
                    ])
                ]))
            }
        }

        // Stage last card initially face-down; will flip in resolveWarBattle
        if pN > 0 {
            let node = makeFaceDownNode(scale: warCardScale)
            node.position = playerCardNode.position
            node.alpha = 0
            addChild(node)
            warPlayerFaceUpNode = node
            let delay = 0.06 * Double(max(pN - 1, 0))
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.08),
                    SKAction.move(to: playerPositions[max(pN - 1, 0)], duration: 0.15)
                ])
            ]))
        }

        if cN > 0 {
            let node = makeFaceDownNode(scale: warCardScale)
            node.position = cpuCardNode.position
            node.alpha = 0
            addChild(node)
            warCPUFaceUpNode = node
            let delay = 0.06 * Double(max(cN - 1, 0))
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.fadeIn(withDuration: 0.08),
                    SKAction.move(to: cpuPositions[max(cN - 1, 0)], duration: 0.15)
                ])
            ]))
        }

        // After dealing finishes, move to resolution
        run(SKAction.wait(forDuration: 0.35)) { [weak self] in
            self?.resolveWarBattle()
        }
    }

    private func gatherWarPileAndAward() {
        // Determine winner based on revealed upcards after resolve
        var winnerIsPlayer = false
        if let p = viewModel.snapshot.playerCard, let c = viewModel.snapshot.cpuCard {
            winnerIsPlayer = p.rank > c.rank
        }

        let pilePoint = warCenter
        let target = winnerIsPlayer ? CGPoint(x: 0, y: -size.height * 0.35) : CGPoint(x: 0, y: size.height * 0.40)

        let allNodes = warAllTempNodes
        for (i, node) in allNodes.enumerated() {
            let delay = 0.04 * Double(i)
            let moveToPile = SKAction.group([
                SKAction.move(to: pilePoint, duration: 0.18),
                SKAction.rotate(byAngle: CGFloat.random(in: -0.06...0.06), duration: 0.18)
            ])
            let moveToWinner = SKAction.group([
                SKAction.move(to: target, duration: 0.22),
                SKAction.fadeOut(withDuration: 0.22)
            ])
            node.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                moveToPile,
                SKAction.wait(forDuration: 0.06),
                moveToWinner,
                SKAction.removeFromParent()
            ]))
        }

        run(SKAction.wait(forDuration: 0.65)) { [weak self] in
            guard let self = self else { return }
            self.resetCardPositions()
            self.warPlayerFaceDownNodes.removeAll()
            self.warCPUFaceDownNodes.removeAll()
            self.warPlayerFaceUpNode = nil
            self.warCPUFaceUpNode = nil
            self.finishTurn()
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
 
