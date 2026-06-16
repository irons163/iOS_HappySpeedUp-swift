//
//  GameCenterUtil.swift
//  HappySpeedUp
//
//  Swift port of GameCenterUtil.{h,m}. Wraps Game Center authentication,
//  leaderboard presentation and score submission. The deprecated GKScore
//  pipeline of the original is modernised to the iOS 14+ GKLeaderboard API
//  while preserving the "store failed scores and resubmit later" behaviour.
//

import GameKit
import UIKit

@objc protocol PauseGameDelegate: AnyObject {
    func pauseGame()
}

final class GameCenterUtil: NSObject, GKGameCenterControllerDelegate {

    static let shared = GameCenterUtil()

    weak var delegate: PauseGameDelegate?

    private let savedScoresKey = "savedScores"

    private override init() {
        super.init()
    }

    /// Game Center is available on every supported deployment target, so this
    /// simply reports whether the framework class is present.
    func isGameCenterAvailable() -> Bool {
        return NSClassFromString("GKLocalPlayer") != nil
    }

    func authenticateLocalUser(_ viewController: UIViewController) {
        let localPlayer = GKLocalPlayer.local
        localPlayer.authenticateHandler = { gcViewController, error in
            if let error = error {
                print(error.localizedDescription)
            }
            if let gcViewController = gcViewController {
                viewController.present(gcViewController, animated: true)
            } else if localPlayer.isAuthenticated {
                print("authenticated no error")
            } else {
                print("authenticated not")
            }
        }
    }

    /// Submits `score` to the given leaderboard, queuing it for a later retry
    /// if the network submission fails.
    func reportScore(_ score: Int, forCategory category: String) {
        if #available(iOS 14.0, *) {
            GKLeaderboard.submitScore(score,
                                      context: 0,
                                      player: GKLocalPlayer.local,
                                      leaderboardIDs: [category]) { [weak self] error in
                if error != nil {
                    self?.storeScoreForLater(score, category: category)
                } else {
                    print("Success.")
                }
            }
        } else {
            storeScoreForLater(score, category: category)
        }
    }

    private func storeScoreForLater(_ score: Int, category: String) {
        var saved = UserDefaults.standard.array(forKey: savedScoresKey) as? [[String: Any]] ?? []
        saved.append(["score": score, "category": category])
        UserDefaults.standard.set(saved, forKey: savedScoresKey)
    }

    /// Re-submits any scores that previously failed to upload.
    func submitAllSavedScores() {
        let saved = UserDefaults.standard.array(forKey: savedScoresKey) as? [[String: Any]] ?? []
        UserDefaults.standard.removeObject(forKey: savedScoresKey)

        for entry in saved {
            guard let score = entry["score"] as? Int,
                  let category = entry["category"] as? String else { continue }
            reportScore(score, forCategory: category)
        }
    }

    /// Presents the standard Game Center leaderboard UI.
    func showGameCenter(_ viewController: UIViewController) {
        let gameView: GKGameCenterViewController
        if #available(iOS 14.0, *) {
            gameView = GKGameCenterViewController(leaderboardID: "com.irons.CrazySplit",
                                                  playerScope: .global,
                                                  timeScope: .allTime)
        } else {
            gameView = GKGameCenterViewController()
            gameView.leaderboardIdentifier = "com.irons.CrazySplit"
        }
        gameView.gameCenterDelegate = self
        viewController.present(gameView, animated: true)
    }

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}
