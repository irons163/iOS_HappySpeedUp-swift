//
//  GameCenterUtilTests.swift
//  HappySpeedUpTests
//
//  Deterministic tests for the Game Center helper. Network-dependent score
//  submission is not exercised here.
//

import XCTest
import GameKit
@testable import HappySpeedUp

final class GameCenterUtilTests: XCTestCase {

    override func tearDown() {
        // A failed async re-submission could repopulate this; keep tests clean.
        UserDefaults.standard.removeObject(forKey: "savedScores")
        super.tearDown()
    }

    func testSharedIsSingleton() {
        XCTAssertTrue(GameCenterUtil.shared === GameCenterUtil.shared)
    }

    func testGameCenterIsAvailable() {
        // GKLocalPlayer is always present in the iOS runtime.
        XCTAssertTrue(GameCenterUtil.shared.isGameCenterAvailable())
    }

    func testSubmitAllSavedScoresClearsTheQueue() {
        // Seed the queue the same way a failed submission would, then confirm
        // submitAllSavedScores drains the persisted key.
        let key = "savedScores"
        UserDefaults.standard.set([["score": 42, "category": "com.irons.HappySpeedUp"]],
                                  forKey: key)

        GameCenterUtil.shared.submitAllSavedScores()

        XCTAssertNil(UserDefaults.standard.array(forKey: key),
                     "the saved-scores key should be removed when the queue is drained")
    }
}
