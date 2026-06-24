//
//  MyUtilsTests.swift
//  HappySpeedUpTests
//
//  Tests the background-music wrapper's safe behaviour when no/invalid audio
//  is available (the test bundle ships no .mp3 files).
//

import XCTest
@testable import HappySpeedUp

final class MyUtilsTests: XCTestCase {

    func testNotPlayingByDefault() {
        XCTAssertFalse(MyUtils.isBackgroundMusicPlayerPlaying)
    }

    func testPreparingMissingFileIsSafe() {
        MyUtils.preparePlayBackgroundMusic("this_file_does_not_exist_123.mp3")
        XCTAssertFalse(MyUtils.isBackgroundMusicPlayerPlaying)
    }

    func testTransportControlsAreSafeWithoutPlayer() {
        // None of these should crash when there is no valid player loaded.
        MyUtils.backgroundMusicPlayerPause()
        MyUtils.backgroundMusicPlayerPlay()
        MyUtils.backgroundMusicPlayerStop()
        XCTAssertFalse(MyUtils.isBackgroundMusicPlayerPlaying)
    }
}
