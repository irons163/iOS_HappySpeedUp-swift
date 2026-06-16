//
//  Wall.swift
//  HappySpeedUp
//
//  Swift port of Wall.{h,m}. The lifecycle predicates delegate to GameEngine
//  so the rules live in exactly one place and stay unit-testable.
//

import SpriteKit

final class Wall: SKSpriteNode {

    /// True once this wall has scrolled far enough down that a new wall line
    /// should be generated above it.
    func isNeedCreateNewInstance() -> Bool {
        GameEngine.wallNeedsNewInstance(atY: position.y)
    }

    /// True once this wall has scrolled off the bottom of the screen.
    func isNeedRemoveInstance() -> Bool {
        GameEngine.wallNeedsRemoval(atY: position.y)
    }

    /// Default downward step (original `move`).
    func move() {
        position = CGPoint(x: position.x, y: position.y - 3)
    }

    /// Downward step by the current vertical speed (original `move:`).
    func move(_ speedY: CGFloat) {
        position = CGPoint(x: position.x, y: position.y - speedY)
    }
}
