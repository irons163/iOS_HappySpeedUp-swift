//
//  GameConstantsTests.swift
//  HappySpeedUpTests
//
//  Locks the ported constant values and raw enum mappings so an accidental
//  edit that changes game balance is caught immediately.
//

import XCTest
@testable import HappySpeedUp

final class GameConstantsTests: XCTestCase {

    func testNumericConstantsMatchOriginal() {
        XCTAssertEqual(GameConstants.baseSpeedX, 6)
        XCTAssertEqual(GameConstants.baseSpeedY, 7) // const int = 7.5 -> 7
        XCTAssertEqual(GameConstants.toolTime, 10)
        XCTAssertEqual(GameConstants.wallLeftAndRightDistance, 230)
        XCTAssertEqual(GameConstants.playerStartX, 160)
        XCTAssertEqual(GameConstants.playerStartY, 200)
        XCTAssertEqual(GameConstants.increaseScoreDistance, 10)
        XCTAssertEqual(GameConstants.toolSpawnScoreInterval, 1500)
        XCTAssertEqual(GameConstants.initialWallLineCount, 60)
    }

    func testToolTypeRawValues() {
        XCTAssertEqual(ToolType.speedUp.rawValue, 0)
        XCTAssertEqual(ToolType.speedDown.rawValue, 1)
        XCTAssertEqual(ToolType.fly.rawValue, 2)
    }

    func testDirectionRawValues() {
        XCTAssertEqual(GameConstants.Direction.left.rawValue, -1)
        XCTAssertEqual(GameConstants.Direction.right.rawValue, 1)
    }
}
