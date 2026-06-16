//
//  GameConstants.swift
//  HappySpeedUp
//
//  Swift port of the constants originally scattered through GameScene.m.
//  Values are kept faithful to the Objective-C source, including the quirk
//  that `BASE_SPEEDY` was declared as `const int = 7.5` and therefore
//  truncates to 7 at runtime.
//

import CoreGraphics

enum GameConstants {
    /// Horizontal speed the player bounces left/right with.
    static let baseSpeedX: CGFloat = 6
    /// Vertical scroll speed. In the original this was `const int = 7.5`,
    /// which truncates to 7 — so we keep 7 here to stay behaviour-compatible.
    static let baseSpeedY: CGFloat = 7

    /// Seconds a tool effect lasts before `resetSpeed` is triggered.
    static let toolTime: Int = 10

    /// Horizontal gap (in points) between the left and right wall columns.
    static let wallLeftAndRightDistance: Int = 230

    /// Player start position.
    static let playerStartX: Int = 160
    static let playerStartY: Int = 200

    /// Score awarded per scoring tick, and the distance threshold for a tick.
    static let increaseScoreDistance: Int = 10

    /// Score interval at which a new tool is spawned.
    static let toolSpawnScoreInterval: Int = 1500

    /// Number of initial wall lines created at game start.
    static let initialWallLineCount: Int = 60

    enum Direction: Int {
        case left = -1
        case right = 1

        var reversed: Direction { self == .left ? .right : .left }
    }
}

/// The three pickups in the game. Raw values match the Objective-C
/// `TOOL_SPEEDUP / TOOL_SPEEDDOWN / TOOL_FLY` integer constants.
enum ToolType: Int {
    case speedUp = 0
    case speedDown = 1
    case fly = 2

    /// Replicates the original spawn distribution from `createToolWithToolX:`,
    /// where `arc4random_uniform(5)` mapped 0–1 -> speedUp, 2–3 -> speedDown,
    /// 4 -> fly. Exposed so it can be exercised deterministically in tests.
    static func from(spawnRoll roll: Int) -> ToolType {
        if roll <= 1 {
            return .speedUp
        } else if roll <= 3 {
            return .speedDown
        } else {
            return .fly
        }
    }
}
