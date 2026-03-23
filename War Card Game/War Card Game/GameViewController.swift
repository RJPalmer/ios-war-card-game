//
//  GameViewController.swift
//  War Card Game
//
//  Created by Robert Palmer on 2/3/26.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Ensure the root view is an SKView
        guard let skView = self.view as? SKView else {
            fatalError("Root view is not an SKView")
        }

        // Load the GameScene from the .sks file
        guard let scene = GameScene(fileNamed: "GameScene") else {
            fatalError("Failed to load GameScene.sks")
        }

        // Configure scene properties
        scene.scaleMode = .aspectFill

        skView.presentScene(scene)
        skView.ignoresSiblingOrder = true
        skView.preferredFramesPerSecond = 60

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = false // Enable true if debugging physics later
        #endif
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
