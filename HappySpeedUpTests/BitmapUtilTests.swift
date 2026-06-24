//
//  BitmapUtilTests.swift
//  HappySpeedUpTests
//
//  Tests for the aspect-ratio sizing maths in BitmapUtil, which preserves the
//  integer truncation of the original Objective-C `(int)(...)` cast.
//

import XCTest
import SpriteKit
import UIKit
@testable import HappySpeedUp

final class BitmapUtilTests: XCTestCase {

    /// Builds a solid-colour texture of an exact point size for deterministic
    /// aspect-ratio assertions.
    private func texture(width: CGFloat, height: CGFloat) -> SKTexture {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }

    func testAspectSizePreservesRatio() {
        let tex = texture(width: 100, height: 200) // ratio 2:1 (h/w)
        let size = BitmapUtil.aspectSize(for: tex, width: 30)
        XCTAssertEqual(size.width, 30)
        // 200/100 * 30 = 60
        XCTAssertEqual(size.height, 60, accuracy: 0.0001)
    }

    func testAspectSizeTruncatesHeight() {
        let tex = texture(width: 100, height: 150) // ratio 1.5
        let size = BitmapUtil.aspectSize(for: tex, width: 33)
        // 150/100 * 33 = 49.5 -> truncated to 49
        XCTAssertEqual(size.width, 33)
        XCTAssertEqual(size.height, 49, accuracy: 0.0001)
    }

    func testAspectSizeHandlesZeroWidthTexture() {
        let tex = SKTexture(image: UIImage()) // size (0,0)
        let size = BitmapUtil.aspectSize(for: tex, width: 30)
        XCTAssertEqual(size.width, 30)
        XCTAssertEqual(size.height, 0)
    }

    func testSharedInstanceComputesPlayerWidth() {
        // footbarWidth = 300 / 4 = 75; playerWidth = 75 / 2.5 = 30.
        // Every game sprite is sized to that width; heights depend on the
        // (absent in tests) textures, so only widths are asserted here.
        let util = BitmapUtil.shared
        XCTAssertEqual(util.wallSize.width, 30)
        XCTAssertEqual(util.speedupSize.width, 30)
        XCTAssertEqual(util.speeddownSize.width, 30)
        XCTAssertEqual(util.flySize.width, 30)
        XCTAssertGreaterThanOrEqual(util.wallSize.height, 0)
    }
}
