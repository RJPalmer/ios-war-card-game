//
//  GameScene.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/3/26.
//

import SpriteKit

final class GameScene: SKScene {

    private let viewModel = GameViewModel()

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

        let verticalSpacing = size.height * 0.15

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

        let playerTextureName = viewModel.playerCardImageName ?? "card_back"
        playerCardNode.texture = SKTexture(imageNamed: playerTextureName)

        let cpuTextureName = viewModel.cpuCardImageName ?? "card_back"
        cpuCardNode.texture = SKTexture(imageNamed: cpuTextureName)

        resultLabel.text = viewModel.resultText
        playerCountLabel.text = "Player Cards: \(viewModel.playerCardCount)"
        cpuCountLabel.text = "CPU Cards: \(viewModel.cpuCardCount)"

        if viewModel.isGameOver {
            playButton.fillColor = .gray
        } else {
            playButton.fillColor = .white
        }
    }

    // MARK: - Touch Handling

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        if nodesAtPoint.contains(where: { $0.name == "playButton" || $0.parent?.name == "playButton" }) {

            guard !viewModel.isGameOver else { return }

            viewModel.playTurn()
            updateUI()
        }
    }
}
 
