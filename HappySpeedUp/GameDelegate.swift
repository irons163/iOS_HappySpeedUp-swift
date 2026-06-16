//
//  GameDelegate.swift
//  HappySpeedUp
//
//  Swift port of the `gameDelegate` protocol declared in GameViewController.h.
//

import Foundation

@objc protocol GameDelegate: AnyObject {
    func showGameOver()
    func showRankView()
    func restartGame()
}
