//
//  GameEngineLifecycleTests.swift
//  HappySpeedUpTests
//
//  Integration-style tests that exercise full tool lifecycles (eat -> effect ->
//  countdown -> reset) and the trickier sign/direction edge cases.
//

import XCTest
@testable import HappySpeedUp

final class GameEngineLifecycleTests: XCTestCase {

    private var engine: GameEngine!

    override func setUp() {
        super.setUp()
        engine = GameEngine()
    }

    /// Runs the per-second timer until the active effect expires, returning the
    /// number of ticks taken (the final tick is the one that resets).
    @discardableResult
    private func runTimerToExpiry() -> Int {
        var ticks = 0
        // Guard against an infinite loop if something regresses.
        while ticks < GameConstants.toolTime + 5 {
            ticks += 1
            if engine.tickToolTimer() { return ticks }
        }
        XCTFail("tool timer never expired")
        return ticks
    }

    // MARK: - Direction

    func testDirectionReversedProperty() {
        XCTAssertEqual(GameConstants.Direction.left.reversed, .right)
        XCTAssertEqual(GameConstants.Direction.right.reversed, .left)
    }

    func testRepeatedTapsAlternateDirection() {
        let expected: [GameConstants.Direction] = [.left, .right, .left, .right]
        var seen: [GameConstants.Direction] = []
        for _ in 0..<4 {
            engine.tap()
            seen.append(engine.direction)
        }
        XCTAssertEqual(seen, expected)
        // Four taps return horizontal speed to its original value.
        XCTAssertEqual(engine.speedX, GameConstants.baseSpeedX, accuracy: 0.0001)
    }

    // MARK: - Sign edge cases

    func testSpeedUpPreservesNegativeSignAndCaps() {
        engine.tap() // speedX -> -6
        engine.applyEffect(.speedUp) // -> -9.9, speedY 10
        engine.applyEffect(.speedUp) // -> -13.8, speedY 13
        XCTAssertEqual(engine.speedX, -13.8, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, 13, accuracy: 0.0001)

        engine.applyEffect(.speedUp) // speedY 13 > 10 -> no-op
        XCTAssertEqual(engine.speedX, -13.8, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, 13, accuracy: 0.0001)
    }

    func testSpeedDownProceedsWhenVerticalSpeedIsHigh() {
        engine.applyEffect(.speedUp) // speedY 10, speedX 9.9
        engine.applyEffect(.speedUp) // speedY 13, speedX 13.8
        engine.applyEffect(.speedDown) // guard fails (speedX 13.8 >= 4) -> proceeds
        XCTAssertEqual(engine.speedX, 9.9, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, 10, accuracy: 0.0001)
    }

    func testFlyZeroesSpeedAndResetGoesNegativeBase() {
        engine.applyEffect(.fly)
        XCTAssertEqual(engine.speedX, 0)
        // resetSpeed: 0 is not > 0, so sign defaults to negative base.
        engine.resetSpeed()
        XCTAssertEqual(engine.speedX, -GameConstants.baseSpeedX, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, GameConstants.baseSpeedY, accuracy: 0.0001)
        XCTAssertTrue(engine.flyFlag)
    }

    // MARK: - Full lifecycles

    func testSpeedUpLifecycleResetsAfterExpiry() {
        engine.eatTool(.speedUp)
        XCTAssertEqual(engine.toolTimeCount, GameConstants.toolTime)

        let ticks = runTimerToExpiry()
        XCTAssertEqual(ticks, GameConstants.toolTime + 1)
        XCTAssertFalse(engine.toolCounterStart)
        XCTAssertEqual(engine.speedX, GameConstants.baseSpeedX, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, GameConstants.baseSpeedY, accuracy: 0.0001)
        XCTAssertFalse(engine.needsFlyResetAnimation)
    }

    func testSpeedDownLifecycleResetsAfterExpiry() {
        engine.eatTool(.speedDown) // speedX 2.1, speedY 4
        runTimerToExpiry()
        XCTAssertEqual(engine.speedX, GameConstants.baseSpeedX, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, GameConstants.baseSpeedY, accuracy: 0.0001)
        XCTAssertFalse(engine.toolCounterStart)
    }

    func testFlyLifecycleNeedsAnimationThenFinishes() {
        engine.eatTool(.fly)
        XCTAssertTrue(engine.flyFlag)
        XCTAssertFalse(engine.checkEatToolable)

        runTimerToExpiry()
        // resetSpeed ran but the fly flag should still be set, signalling that
        // the scale-down animation must play before it clears.
        XCTAssertTrue(engine.needsFlyResetAnimation)

        engine.finishFlyReset()
        XCTAssertFalse(engine.flyFlag)
        XCTAssertTrue(engine.checkEatToolable)
    }
}
