//
//  GameSceneTests.swift
//  HappySpeedUpTests
//
//  Light-weight tests that the scene is wired to its GameEngine. These don't
//  present the scene in an SKView (so `didMove(to:)` is not invoked); they only
//  verify the exposed state and the engine bridge.
//

import XCTest
import SpriteKit
@testable import HappySpeedUp

final class GameSceneTests: XCTestCase {

    private func makeScene() -> GameScene {
        GameScene(size: CGSize(width: 320, height: 480))
    }

    func testFreshSceneStartsAtZeroScore() {
        let scene = makeScene()
        XCTAssertEqual(scene.gameScoreForDistance, 0)
        XCTAssertFalse(scene.engine.gameOver)
        XCTAssertTrue(scene.engine.readyFlag)
        XCTAssertEqual(scene.lastUpdateTimeInterval, 0)
        XCTAssertEqual(scene.lastSpawnTimeInterval, 0)
    }

    func testExposedScoreFollowsEngine() {
        let scene = makeScene()
        // Two ticks of distance accumulation -> first score increment (10).
        _ = scene.engine.advanceDistance()
        _ = scene.engine.advanceDistance()
        XCTAssertEqual(scene.gameScoreForDistance, scene.engine.score)
        XCTAssertEqual(scene.gameScoreForDistance, 10)
    }

    func testEngineTapFlipsHorizontalSpeed() {
        let scene = makeScene()
        let before = scene.engine.speedX
        scene.engine.tap()
        XCTAssertEqual(scene.engine.speedX, -before)
    }
}
