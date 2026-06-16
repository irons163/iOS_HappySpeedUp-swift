//
//  GameViewController.swift
//  HappySpeedUp
//
//  Swift port of GameViewController.{h,m}. Hosts the SpriteKit scene and acts
//  as the game delegate, bridging to Game Center and the game-over screen.
//

import UIKit
import SpriteKit

final class GameViewController: UIViewController, GameDelegate {

    private var scene: GameScene?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let skView = self.view as? SKView else { return }
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true

        initAndAddScene(skView)
    }

    private func initAndAddScene(_ skView: SKView) {
        let newScene = GameScene(size: view.bounds.size)
        newScene.size = view.frame.size
        newScene.scaleMode = .aspectFill
        newScene.gameDelegate = self
        skView.presentScene(newScene)
        scene = newScene
    }

    // MARK: - GameDelegate

    func showRankView() {
        let gameCenterUtil = GameCenterUtil.shared
        _ = gameCenterUtil.isGameCenterAvailable()
        gameCenterUtil.showGameCenter(self)
        gameCenterUtil.submitAllSavedScores()
    }

    func showGameOver() {
        guard let gameOverVC = storyboard?.instantiateViewController(
            withIdentifier: "GameOverViewController") as? GameOverViewController else { return }

        gameOverVC.gameDelegate = self
        gameOverVC.gameScoreForDistance = scene?.gameScoreForDistance ?? 0

        navigationController?.providesPresentationContextTransitionStyle = true
        navigationController?.definesPresentationContext = true

        gameOverVC.modalPresentationStyle = .overCurrentContext
        present(gameOverVC, animated: true)
    }

    func restartGame() {
        guard let skView = self.view as? SKView else { return }
        initAndAddScene(skView)
    }

    override var shouldAutorotate: Bool { true }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        UIDevice.current.userInterfaceIdiom == .phone ? .allButUpsideDown : .all
    }

    override var prefersStatusBarHidden: Bool { true }
}
