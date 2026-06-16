//
//  GameEngine.swift
//  HappySpeedUp
//
//  Pure (UIKit/SpriteKit-free) game logic extracted from GameScene.m so that
//  it can be unit-tested in isolation. GameScene owns an instance of this and
//  drives all of its numeric state through here, which keeps the rendering
//  layer thin and the rules verifiable.
//

import CoreGraphics

/// Result of advancing the distance counter on a movement tick.
struct DistanceResult: Equatable {
    /// The score increased on this tick.
    var didScore: Bool
    /// A new tool should be spawned (score crossed a 1500 multiple).
    var shouldSpawnTool: Bool
}

final class GameEngine {

    // MARK: - Mutable state (mirrors the ivars of GameScene)

    private(set) var speedX: CGFloat
    private(set) var speedY: CGFloat
    private(set) var direction: GameConstants.Direction

    private(set) var score: Int = 0
    private(set) var distanceCount: Int = 0

    private(set) var toolTimeCount: Int = 0
    private(set) var toolCounterStart: Bool = false

    private(set) var flyFlag: Bool = false
    private(set) var checkEatToolable: Bool = true
    private(set) var gameOver: Bool = false
    var readyFlag: Bool = true

    // MARK: - Init

    init() {
        speedX = GameConstants.baseSpeedX
        speedY = GameConstants.baseSpeedY
        direction = .right
    }

    // MARK: - Input

    /// A tap reverses both the logical direction and the horizontal speed.
    /// Faithful to `touchesBegan:` which did `direction = -direction;
    /// speedX = -speedX;` unconditionally.
    func tap() {
        direction = direction.reversed
        speedX = -speedX
    }

    // MARK: - Tools

    /// Called when the player eats a tool (`checkEatTool`). Applies the effect
    /// and (re)charges the effect timer to `toolTime`.
    func eatTool(_ type: ToolType) {
        applyEffect(type)
        toolTimeCount = GameConstants.toolTime
    }

    /// Applies a tool's effect to the speed state (`doToolEffect:`).
    func applyEffect(_ type: ToolType) {
        switch type {
        case .speedUp: speedUp()
        case .speedDown: speedDown()
        case .fly: fly()
        }
    }

    private func speedUp() {
        // Cap: once vertical speed is past 10 we stop boosting.
        if speedY > 10 { return }

        if speedX > 0 {
            speedX += 3.9
        } else {
            speedX -= 3.9
        }
        speedY += 3
        toolCounterStart = true
    }

    private func speedDown() {
        // Floor guard from the original (note: both clauses must hold to bail).
        if speedX < 4 && speedY < 42 { return }

        if speedX > 0 {
            speedX -= 3.9
        } else {
            speedX += 3.9
        }
        speedY -= 3
        toolCounterStart = true
    }

    private func fly() {
        flyFlag = true
        speedX = 0
        toolCounterStart = true
        checkEatToolable = false
    }

    /// Advances the per-second tool timer (`countToolTimer`). Returns true when
    /// the effect has just expired and `resetSpeed` was applied this tick.
    @discardableResult
    func tickToolTimer() -> Bool {
        if toolCounterStart && toolTimeCount <= 0 {
            toolCounterStart = false
            resetSpeed()
            return true
        } else if !toolCounterStart {
            return false
        }
        toolTimeCount -= 1
        return false
    }

    /// Resets speeds back to base values, preserving horizontal sign
    /// (`resetSpeed`). The fly flag is *not* cleared here — in the original a
    /// 2-second scale-down animation clears it afterwards; call
    /// `finishFlyReset()` when that animation completes.
    func resetSpeed() {
        speedX = speedX > 0 ? GameConstants.baseSpeedX : -GameConstants.baseSpeedX
        speedY = GameConstants.baseSpeedY
    }

    /// Whether `resetSpeed` left a pending fly-reset animation to run.
    var needsFlyResetAnimation: Bool { flyFlag }

    /// Completes the fly reset once the scale-down animation has finished.
    func finishFlyReset() {
        flyFlag = false
        checkEatToolable = true
    }

    // MARK: - Movement / scoring

    /// Advances the travelled-distance counter by `speedY` and converts it into
    /// score in `increaseScoreDistance` chunks (`move`). Mirrors the original
    /// integer truncation: `distanceCount += speedY` where distanceCount is int.
    func advanceDistance() -> DistanceResult {
        distanceCount = Int(CGFloat(distanceCount) + speedY)

        let step = GameConstants.increaseScoreDistance
        if distanceCount < step {
            return DistanceResult(didScore: false, shouldSpawnTool: false)
        }
        distanceCount -= step
        score += step

        let shouldSpawn = score % GameConstants.toolSpawnScoreInterval == 0
        return DistanceResult(didScore: true, shouldSpawnTool: shouldSpawn)
    }

    // MARK: - Collision

    /// Marks the game as over (used when a wall collision is detected).
    func registerCollision() {
        gameOver = true
    }

    /// Collision test matching `isCollision:withOeject:` — the player's
    /// effective hit-box is the centre 50% of its frame, intersected with the
    /// object's full frame.
    static func isCollision(playerFrame: CGRect, objectFrame: CGRect) -> Bool {
        let hitBox = CGRect(
            x: playerFrame.origin.x + playerFrame.size.width * 0.25,
            y: playerFrame.origin.y + playerFrame.size.height * 0.25,
            width: playerFrame.size.width * 0.5,
            height: playerFrame.size.height * 0.5
        )
        return hitBox.intersects(objectFrame)
    }

    // MARK: - Wall / tool lifecycle predicates (pure)

    /// A wall column needs a fresh line spawned above it once it has scrolled
    /// down to y >= 50 (`Wall.isNeedCreateNewInstance`).
    static func wallNeedsNewInstance(atY y: CGFloat) -> Bool { y >= 50 }

    /// A wall column should be removed once it scrolls off the bottom, y <= 0
    /// (`Wall.isNeedRemoveInstance`).
    static func wallNeedsRemoval(atY y: CGFloat) -> Bool { y <= 0 }

    /// A tool should be removed once it scrolls below the screen, y < 0
    /// (`Tool.isNeedRemoveInstance`).
    static func toolNeedsRemoval(atY y: CGFloat) -> Bool { y < 0 }
}
