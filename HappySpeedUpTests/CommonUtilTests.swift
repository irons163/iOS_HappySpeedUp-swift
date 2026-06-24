//
//  CommonUtilTests.swift
//  HappySpeedUpTests
//
//  Tests the shared screen-dimension holder.
//

import XCTest
import SpriteKit
@testable import HappySpeedUp

final class CommonUtilTests: XCTestCase {

    func testSharedIsSingleton() {
        XCTAssertTrue(CommonUtil.shared === CommonUtil.shared)
    }

    func testIsSpriteNodeSubclass() {
        XCTAssertTrue(CommonUtil.shared is SKSpriteNode)
    }

    func testStoresScreenDimensions() {
        CommonUtil.shared.screenWidth = 320
        CommonUtil.shared.screenHeight = 480
        XCTAssertEqual(CommonUtil.shared.screenWidth, 320)
        XCTAssertEqual(CommonUtil.shared.screenHeight, 480)
    }
}
