//
//  ToolTests.swift
//  HappySpeedUpTests
//
//  Tests for the Tool node and the ToolType spawn distribution.
//

import XCTest
import SpriteKit
@testable import HappySpeedUp

final class ToolTests: XCTestCase {

    func testDefaultTypeIsSpeedUp() {
        let tool = Tool()
        XCTAssertEqual(tool.type, ToolType.speedUp.rawValue)
        XCTAssertEqual(tool.toolType, .speedUp)
    }

    func testTypeRoundTrips() {
        let tool = Tool()
        tool.toolType = .fly
        XCTAssertEqual(tool.type, ToolType.fly.rawValue)
        XCTAssertEqual(tool.type, 2)

        tool.type = ToolType.speedDown.rawValue
        XCTAssertEqual(tool.toolType, .speedDown)
    }

    func testRemovalThreshold() {
        let tool = Tool()
        tool.position = CGPoint(x: 0, y: -1)
        XCTAssertTrue(tool.isNeedRemoveInstance())

        tool.position = CGPoint(x: 0, y: 0)
        XCTAssertFalse(tool.isNeedRemoveInstance())

        tool.position = CGPoint(x: 0, y: 5)
        XCTAssertFalse(tool.isNeedRemoveInstance())
    }

    func testSpawnRollDistributionMatchesOriginal() {
        // arc4random_uniform(5): 0–1 -> speedUp, 2–3 -> speedDown, 4 -> fly.
        XCTAssertEqual(ToolType.from(spawnRoll: 0), .speedUp)
        XCTAssertEqual(ToolType.from(spawnRoll: 1), .speedUp)
        XCTAssertEqual(ToolType.from(spawnRoll: 2), .speedDown)
        XCTAssertEqual(ToolType.from(spawnRoll: 3), .speedDown)
        XCTAssertEqual(ToolType.from(spawnRoll: 4), .fly)
    }
}
