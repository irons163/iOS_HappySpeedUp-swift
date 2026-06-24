//
//  CollisionTests.swift
//  HappySpeedUpTests
//
//  Tests for the collision hit-box logic. The player's effective hit-box is
//  the centre 50% of its frame (inset 25% on each side), intersected with the
//  object's full frame.
//

import XCTest
import CoreGraphics
@testable import HappySpeedUp

final class CollisionTests: XCTestCase {

    // Player frame 40x40 at origin -> hit-box is x[10,30], y[10,30].
    private let playerFrame = CGRect(x: 0, y: 0, width: 40, height: 40)

    func testOverlapWithCentreReturnsTrue() {
        let object = CGRect(x: 25, y: 25, width: 10, height: 10) // x[25,35]
        XCTAssertTrue(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testCornerOutsideCentreReturnsFalse() {
        // Sits in the player's outer frame but outside the centre hit-box.
        let object = CGRect(x: 0, y: 0, width: 8, height: 8) // x[0,8], hit-box starts at 10
        XCTAssertFalse(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testJustInsideRightEdgeReturnsTrue() {
        let object = CGRect(x: 29, y: 15, width: 5, height: 5) // x[29,34] overlaps 29..30
        XCTAssertTrue(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testFarRightOfCentreReturnsFalse() {
        let object = CGRect(x: 31, y: 15, width: 5, height: 5) // x[31,36], hit-box ends at 30
        XCTAssertFalse(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testFullyContainedReturnsTrue() {
        let object = CGRect(x: 18, y: 18, width: 4, height: 4)
        XCTAssertTrue(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testHitBoxRespectsPlayerOffset() {
        // Player frame offset to (100,100); hit-box is x[110,130], y[110,130].
        let offsetPlayer = CGRect(x: 100, y: 100, width: 40, height: 40)
        let hit = CGRect(x: 115, y: 115, width: 6, height: 6)
        let miss = CGRect(x: 100, y: 100, width: 6, height: 6)
        XCTAssertTrue(GameEngine.isCollision(playerFrame: offsetPlayer, objectFrame: hit))
        XCTAssertFalse(GameEngine.isCollision(playerFrame: offsetPlayer, objectFrame: miss))
    }

    func testEdgeTouchingReturnsFalse() {
        // Object's left edge sits exactly on the hit-box's right edge (x = 30).
        // CGRect intersection of edge-only contact is false.
        let object = CGRect(x: 30, y: 15, width: 5, height: 5)
        XCTAssertFalse(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testObjectMatchingHitBoxReturnsTrue() {
        // Exactly the centre 50% hit-box (x[10,30], y[10,30]).
        let object = CGRect(x: 10, y: 10, width: 20, height: 20)
        XCTAssertTrue(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }

    func testObjectEnclosingPlayerReturnsTrue() {
        let object = CGRect(x: -50, y: -50, width: 200, height: 200)
        XCTAssertTrue(GameEngine.isCollision(playerFrame: playerFrame, objectFrame: object))
    }
}
