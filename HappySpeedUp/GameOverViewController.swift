//
//  GameOverViewController.swift
//  HappySpeedUp
//
//  Swift port of GameOverViewController.{h,m}. Shows the final score and a
//  restart button.
//

import UIKit

final class GameOverViewController: UIViewController {

    @IBOutlet weak var gameTimeLabel: UILabel?

    weak var gameDelegate: GameDelegate?
    var gameScoreForDistance: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        gameTimeLabel?.text = "\(gameScoreForDistance)"
    }

    @IBAction func restartClick(_ sender: Any) {
        dismiss(animated: true) { [weak self] in
            self?.gameDelegate?.restartGame()
        }
    }
}
