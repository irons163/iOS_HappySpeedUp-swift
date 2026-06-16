//
//  WallTests.swift
//  HappySpeedUpTests
//
//  Tests for the Wall SpriteKit node: lifecycle predicates and movement.
//

import XCTest
import SpriteKit
@testable import HappySpeedUp

final class WallTests: XCTestCase {

    func testNeedsNewInstanceThreshold() {
        let wall = Wall()
        wall.position = CGPoint(x: 0, y: 50)
        XCTAssertTrue(wall.isNeedCreateNewInstance())

        wall.position = CGPoint(x: 0, y: 49)
        XCTAssertFalse(wall.isNeedCreateNewInstance())

        wall.position = CGPoint(x: 0, y: 200)
        XCTAssertTrue(wall.isNeedCreateNewInstance())
    }

    func testNeedsRemovalThreshold() {
        let wall = Wall()
        wall.position = CGPoint(x: 0, y: 0)
        XCTAssertTrue(wall.isNeedRemoveInstance())

        wall.position = CGPoint(x: 0, y: -5)
        XCTAssertTrue(wall.isNeedRemoveInstance())

        wall.position = CGPoint(x: 0, y: 1)
        XCTAssertFalse(wall.isNeedRemoveInstance())
    }

    func testDefaultMoveStepsDownByThree() {
        let wall = Wall()
        wall.position = CGPoint(x: 10, y: 100)
        wall.move()
        XCTAssertEqual(wall.position.x, 10)
        XCTAssertEqual(wall.position.y, 97)
    }

    func testMoveBySpeed() {
        let wall = Wall()
        wall.position = CGPoint(x: 10, y: 100)
        wall.move(7.5)
        XCTAssertEqual(wall.position.x, 10)
        XCTAssertEqual(wall.position.y, 92.5, accuracy: 0.0001)
    }
}
