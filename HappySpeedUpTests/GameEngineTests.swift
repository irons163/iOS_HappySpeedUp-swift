//
//  GameEngineTests.swift
//  HappySpeedUpTests
//
//  Unit tests for the pure game logic in GameEngine. These verify the speed,
//  tool, timer and reset rules ported from GameScene.m.
//

import XCTest
@testable import HappySpeedUp

final class GameEngineTests: XCTestCase {

    private var engine: GameEngine!

    override func setUp() {
        super.setUp()
        engine = GameEngine()
    }

    // MARK: - Initial state

    func testInitialState() {
        XCTAssertEqual(engine.speedX, GameConstants.baseSpeedX)
        XCTAssertEqual(engine.speedY, GameConstants.baseSpeedY)
        XCTAssertEqual(engine.speedY, 7, "BASE_SPEEDY truncates 7.5 -> 7 in the original")
        XCTAssertEqual(engine.direction, .right)
        XCTAssertEqual(engine.score, 0)
        XCTAssertEqual(engine.distanceCount, 0)
        XCTAssertFalse(engine.gameOver)
        XCTAssertFalse(engine.flyFlag)
        XCTAssertTrue(engine.checkEatToolable)
        XCTAssertFalse(engine.toolCounterStart)
        XCTAssertTrue(engine.readyFlag)
    }

    // MARK: - Tap

    func testTapReversesDirectionAndHorizontalSpeed() {
        engine.tap()
        XCTAssertEqual(engine.direction, .left)
        XCTAssertEqual(engine.speedX, -GameConstants.baseSpeedX)

        engine.tap()
        XCTAssertEqual(engine.direction, .right)
        XCTAssertEqual(engine.speedX, GameConstants.baseSpeedX)
    }

    // MARK: - Speed up

    func testSpeedUpBoostsAndPreservesPositiveSign() {
        engine.applyEffect(.speedUp)
        XCTAssertEqual(engine.speedX, 9.9, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, 10, accuracy: 0.0001)
        XCTAssertTrue(engine.toolCounterStart)
    }

    func testSpeedUpPreservesNegativeSign() {
        engine.tap() // speedX -> -6
        engine.applyEffect(.speedUp)
        XCTAssertEqual(engine.speedX, -9.9, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, 10, accuracy: 0.0001)
    }

    func testSpeedUpIsCappedAboveVerticalSpeedTen() {
        engine.applyEffect(.speedUp) // speedY 7 -> 10
        engine.applyEffect(.speedUp) // speedY 10 -> 13
        XCTAssertEqual(engine.speedY, 13, accuracy: 0.0001)

        let xBefore = engine.speedX
        engine.applyEffect(.speedUp) // speedY 13 > 10 -> no-op
        XCTAssertEqual(engine.speedY, 13, accuracy: 0.0001)
        XCTAssertEqual(engine.speedX, xBefore, accuracy: 0.0001)
    }

    // MARK: - Speed down

    func testSpeedDownDecreasesFromBase() {
        engine.applyEffect(.speedDown)
        XCTAssertEqual(engine.speedX, 2.1, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, 4, accuracy: 0.0001)
        XCTAssertTrue(engine.toolCounterStart)
    }

    func testSpeedDownGuardStopsWhenSlow() {
        engine.applyEffect(.speedDown) // speedX 2.1, speedY 4
        let xBefore = engine.speedX
        let yBefore = engine.speedY
        engine.applyEffect(.speedDown) // guard: speedX<4 && speedY<42 -> no-op
        XCTAssertEqual(engine.speedX, xBefore, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, yBefore, accuracy: 0.0001)
    }

    // MARK: - Fly

    func testFlySetsFlagsAndZeroesHorizontalSpeed() {
        engine.applyEffect(.fly)
        XCTAssertTrue(engine.flyFlag)
        XCTAssertEqual(engine.speedX, 0)
        XCTAssertTrue(engine.toolCounterStart)
        XCTAssertFalse(engine.checkEatToolable)
        XCTAssertTrue(engine.needsFlyResetAnimation)
    }

    // MARK: - Eat tool charges timer

    func testEatToolChargesTimer() {
        engine.eatTool(.speedUp)
        XCTAssertEqual(engine.toolTimeCount, GameConstants.toolTime)
        XCTAssertTrue(engine.toolCounterStart)
    }

    // MARK: - Tool timer

    func testToolTimerNoOpWhenNotStarted() {
        XCTAssertFalse(engine.tickToolTimer())
        XCTAssertEqual(engine.toolTimeCount, 0)
        XCTAssertFalse(engine.toolCounterStart)
    }

    func testToolTimerCountsDownThenResets() {
        engine.eatTool(.speedUp) // counter started, count = 10, speeds boosted
        for _ in 0..<GameConstants.toolTime {
            XCTAssertFalse(engine.tickToolTimer())
        }
        XCTAssertEqual(engine.toolTimeCount, 0)

        // The next tick expires the effect and resets speeds.
        XCTAssertTrue(engine.tickToolTimer())
        XCTAssertFalse(engine.toolCounterStart)
        XCTAssertEqual(engine.speedX, GameConstants.baseSpeedX, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, GameConstants.baseSpeedY, accuracy: 0.0001)
    }

    // MARK: - Reset speed

    func testResetSpeedPreservesSign() {
        engine.tap()             // speedX -> -6
        engine.applyEffect(.speedUp) // speedX -> -9.9, speedY -> 10
        engine.resetSpeed()
        XCTAssertEqual(engine.speedX, -GameConstants.baseSpeedX, accuracy: 0.0001)
        XCTAssertEqual(engine.speedY, GameConstants.baseSpeedY, accuracy: 0.0001)
    }

    func testFinishFlyResetClearsFlags() {
        engine.applyEffect(.fly)
        engine.resetSpeed()
        XCTAssertTrue(engine.flyFlag, "flyFlag stays set until the animation completes")
        engine.finishFlyReset()
        XCTAssertFalse(engine.flyFlag)
        XCTAssertTrue(engine.checkEatToolable)
    }

    // MARK: - Collision flag

    func testRegisterCollisionEndsGame() {
        XCTAssertFalse(engine.gameOver)
        engine.registerCollision()
        XCTAssertTrue(engine.gameOver)
    }

    // MARK: - Lifecycle predicates

    func testWallAndToolPredicates() {
        XCTAssertTrue(GameEngine.wallNeedsNewInstance(atY: 50))
        XCTAssertTrue(GameEngine.wallNeedsNewInstance(atY: 80))
        XCTAssertFalse(GameEngine.wallNeedsNewInstance(atY: 49))

        XCTAssertTrue(GameEngine.wallNeedsRemoval(atY: 0))
        XCTAssertTrue(GameEngine.wallNeedsRemoval(atY: -10))
        XCTAssertFalse(GameEngine.wallNeedsRemoval(atY: 1))

        XCTAssertTrue(GameEngine.toolNeedsRemoval(atY: -1))
        XCTAssertFalse(GameEngine.toolNeedsRemoval(atY: 0))
        XCTAssertFalse(GameEngine.toolNeedsRemoval(atY: 5))
    }
}
