//
//  ScoringTests.swift
//  HappySpeedUpTests
//
//  Tests for distance accumulation, scoring cadence and tool-spawn milestones.
//

import XCTest
@testable import HappySpeedUp

final class ScoringTests: XCTestCase {

    func testDistanceAccumulatesBeforeScoring() {
        let engine = GameEngine()

        // speedY == 7. First tick: 0 + 7 = 7 (< 10) -> no score yet.
        let first = engine.advanceDistance()
        XCTAssertFalse(first.didScore)
        XCTAssertFalse(first.shouldSpawnTool)
        XCTAssertEqual(engine.distanceCount, 7)
        XCTAssertEqual(engine.score, 0)

        // Second tick: 7 + 7 = 14 (>= 10) -> score += 10, distance -> 4.
        let second = engine.advanceDistance()
        XCTAssertTrue(second.didScore)
        XCTAssertFalse(second.shouldSpawnTool)
        XCTAssertEqual(engine.distanceCount, 4)
        XCTAssertEqual(engine.score, 10)
    }

    func testScoreIncrementsInTensAndIsMonotonic() {
        let engine = GameEngine()
        var lastScore = 0
        for _ in 0..<300 {
            _ = engine.advanceDistance()
            XCTAssertGreaterThanOrEqual(engine.score, lastScore)
            XCTAssertEqual(engine.score % GameConstants.increaseScoreDistance, 0)
            lastScore = engine.score
        }
        XCTAssertGreaterThan(engine.score, 0)
    }

    func testToolSpawnsAtScoreMilestone() {
        let engine = GameEngine()
        var spawnScores: [Int] = []

        // Drive far enough to cross the first 1500 milestone.
        while engine.score < GameConstants.toolSpawnScoreInterval {
            let result = engine.advanceDistance()
            if result.shouldSpawnTool {
                spawnScores.append(engine.score)
            }
        }

        XCTAssertEqual(spawnScores, [GameConstants.toolSpawnScoreInterval],
                       "A tool should spawn exactly when the score first hits 1500")
    }

    func testNoSpawnOnNonMilestoneScores() {
        let engine = GameEngine()
        // Get to the first scoring tick (score 10) and confirm no spawn.
        _ = engine.advanceDistance() // 7
        let scored = engine.advanceDistance() // 14 -> score 10
        XCTAssertEqual(engine.score, 10)
        XCTAssertFalse(scored.shouldSpawnTool)
    }

    func testCumulativeScoreFollowsDistanceFormula() {
        let engine = GameEngine()
        // speedY == 7, so after K ticks total distance is 7K and score is
        // 10 * floor(7K / 10) with the remainder carried in distanceCount.
        for _ in 0..<10 { _ = engine.advanceDistance() }
        XCTAssertEqual(engine.score, 70)      // 10 * floor(70 / 10)
        XCTAssertEqual(engine.distanceCount, 0)

        _ = engine.advanceDistance()           // total distance 77
        XCTAssertEqual(engine.score, 70)
        XCTAssertEqual(engine.distanceCount, 7)
    }
}
