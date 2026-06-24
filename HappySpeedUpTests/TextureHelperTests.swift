//
//  TextureHelperTests.swift
//  HappySpeedUpTests
//
//  Tests for the sprite-sheet slicing geometry and sequence selection.
//

import XCTest
import CoreGraphics
@testable import HappySpeedUp

final class TextureHelperTests: XCTestCase {

    // MARK: - frameRects

    func testFrameRectCountIsRowsTimesCols() {
        let rects = TextureHelper.frameRects(sheetSize: CGSize(width: 100, height: 100),
                                             source: CGRect(x: 0, y: 0, width: 10, height: 10),
                                             rows: 2,
                                             cols: 7)
        XCTAssertEqual(rects.count, 14)
    }

    func testFrameRectsAreNormalised() {
        // 10x20 sprite on a 100x100 sheet -> 0.1 wide, 0.2 tall.
        let rects = TextureHelper.frameRects(sheetSize: CGSize(width: 100, height: 100),
                                             source: CGRect(x: 0, y: 0, width: 10, height: 20),
                                             rows: 1,
                                             cols: 2)
        XCTAssertEqual(rects.count, 2)
        XCTAssertEqual(rects[0], CGRect(x: 0, y: 0, width: 0.1, height: 0.2))
        XCTAssertEqual(rects[1], CGRect(x: 0.1, y: 0, width: 0.1, height: 0.2))
    }

    func testFrameRectsWrapToNextRow() {
        // 2x2 grid of 10x10 cells on a 100x100 sheet.
        let rects = TextureHelper.frameRects(sheetSize: CGSize(width: 100, height: 100),
                                             source: CGRect(x: 0, y: 0, width: 10, height: 10),
                                             rows: 2,
                                             cols: 2)
        XCTAssertEqual(rects.count, 4)
        XCTAssertEqual(rects[0].origin, CGPoint(x: 0, y: 0))
        XCTAssertEqual(rects[1].origin, CGPoint(x: 0.1, y: 0))
        // Index 2 wraps to the start of the second row.
        XCTAssertEqual(rects[2].origin.x, 0, accuracy: 0.0001)
        XCTAssertEqual(rects[2].origin.y, 0.1, accuracy: 0.0001)
        XCTAssertEqual(rects[3].origin.x, 0.1, accuracy: 0.0001)
        XCTAssertEqual(rects[3].origin.y, 0.1, accuracy: 0.0001)
    }

    func testFrameRectsGuardOnZeroOrEmpty() {
        XCTAssertTrue(TextureHelper.frameRects(sheetSize: .zero,
                                               source: CGRect(x: 0, y: 0, width: 10, height: 10),
                                               rows: 2, cols: 2).isEmpty)
        XCTAssertTrue(TextureHelper.frameRects(sheetSize: CGSize(width: 100, height: 100),
                                               source: CGRect(x: 0, y: 0, width: 10, height: 10),
                                               rows: 0, cols: 2).isEmpty)
    }

    // MARK: - pick

    func testPickSelectsRequestedIndices() {
        let frames = Array(0..<14)
        XCTAssertEqual(TextureHelper.pick(frames, at: [7, 8]), [7, 8])
    }

    func testPickSkipsOutOfRangeIndices() {
        let frames = [10, 20, 30]
        XCTAssertEqual(TextureHelper.pick(frames, at: [0, 5, 2]), [10, 30])
    }

    func testPickPreservesOrderAndDuplicates() {
        let frames = ["a", "b", "c"]
        XCTAssertEqual(TextureHelper.pick(frames, at: [2, 0, 0]), ["c", "a", "a"])
    }
}
