//
//  GameScene.swift
//  HappySpeedUp
//
//  Swift port of GameScene.{h,m}. The numeric game state (speeds, score,
//  tool timers, collision rules) lives in `GameEngine`; this class owns the
//  SpriteKit nodes and drives the engine from the run loop.
//
//  The class is split across several files by responsibility:
//    - GameScene.swift        : state, run loop, input, move orchestration
//    - GameScene+Walls.swift  : wall creation / scrolling / collision
//    - GameScene+Tools.swift  : tool pickups and fly visuals
//    - GameScene+UI.swift     : HUD, buttons, timers, background, player setup
//
//  Stored properties are declared here (extensions cannot add stored
//  properties) with internal access so the sibling extension files can use
//  them.
//

import SpriteKit
import UIKit

final class GameScene: SKScene {

    weak var gameDelegate: GameDelegate?

    var lastUpdateTimeInterval: TimeInterval = 0
    var lastSpawnTimeInterval: TimeInterval = 0

    /// Pure, unit-tested game logic.
    let engine = GameEngine()

    /// Exposed for GameViewController / GameOverViewController.
    var gameScoreForDistance: Int { engine.score }

    // MARK: - Nodes & helpers (internal so the GameScene+* extensions can use them)

    var bitmapUtil: BitmapUtil = .shared
    var offsetX: Int = 0
    var offsetY: Int = 0

    var backgroundNode: SKSpriteNode?
    var backgroundNode2: SKSpriteNode?
    var backgroundMovePointsPerSec: CGFloat = 0

    var gameScoreForDistanceLabel: SKLabelNode?

    var readyStep: Int = 0
    var theReadyTimer: Timer?
    var theToolTimer: Timer?
    var readyLabel: SKLabelNode?

    var rankBtn: SKSpriteNode?
    var myAdView: MyADView?

    var musicBtnTextures: [SKTexture] = []
    var musicBtn: SKSpriteNode?

    var walls: [[Wall]] = []
    var tools: [Tool] = []
    var player: Player?

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        walls = []
        tools = []
        initGame()
        getBackground()

        if let bg = backgroundNode { addChild(bg) }
        backgroundMovePointsPerSec = engine.speedY
        createInitWall()
        createPlayer()
        initGameScoreForDistanceLabel()
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if let rankBtn = rankBtn,
               rankBtn.calculateAccumulatedFrame().contains(location) {
                gameDelegate?.showRankView()
            } else if let musicBtn = musicBtn,
                      musicBtn.calculateAccumulatedFrame().contains(location) {
                if MyUtils.isBackgroundMusicPlayerPlaying {
                    MyUtils.backgroundMusicPlayerPause()
                    musicBtn.texture = musicBtnTextures[1]
                    UserDefaults.standard.set(false, forKey: "isPlayMusic")
                } else {
                    MyUtils.backgroundMusicPlayerPlay()
                    musicBtn.texture = musicBtnTextures[0]
                    UserDefaults.standard.set(true, forKey: "isPlayMusic")
                }
            }
        }

        engine.tap()
    }

    // MARK: - Run loop

    override func update(_ currentTime: TimeInterval) {
        if engine.readyFlag && theReadyTimer == nil {
            initReadyTimer()
            initToolTimer()
        }

        if engine.gameOver || engine.readyFlag { return }

        var timeSinceLast = currentTime - lastUpdateTimeInterval
        lastUpdateTimeInterval = currentTime
        if timeSinceLast > 1 {
            timeSinceLast = 1.0 / 60.0
            lastUpdateTimeInterval = currentTime
        }

        updateWithTimeSinceLastUpdate(timeSinceLast)
    }

    private func updateWithTimeSinceLastUpdate(_ timeSinceLast: TimeInterval) {
        lastSpawnTimeInterval += timeSinceLast
        if lastSpawnTimeInterval > 0.05 {
            lastSpawnTimeInterval = 0
            move()
            if engine.checkEatToolable {
                checkEatTool()
            }
            checkRemoveTools()
        }
    }

    // MARK: - Movement orchestration

    func move() {
        moveBg()

        guard let player = player else { return }
        var offsetXByWallCorrecX: CGFloat = 0

        if engine.flyFlag {
            outer: for wallLine in walls {
                for wall in wallLine {
                    if wall.position.y > player.position.y - player.size.height / 2,
                       wall.position.y < player.position.y + player.size.height / 2 {
                        let wallCorrectLeftX = player.position.x - CGFloat(GameConstants.wallLeftAndRightDistance) / 2
                        offsetXByWallCorrecX = wall.position.x - wallCorrectLeftX
                        break outer
                    }
                }
            }
        }

        for wallLine in walls {
            for wall in wallLine {
                if engine.flyFlag {
                    wall.position = CGPoint(x: wall.position.x - offsetXByWallCorrecX, y: wall.position.y)
                } else {
                    wall.position = CGPoint(x: wall.position.x - engine.speedX, y: wall.position.y)
                }
            }
        }

        if engine.flyFlag {
            moveTools(offsetXByWallCorrecX)
        } else {
            moveTools(engine.speedX)
        }

        doWallMoveAndCollisionDetectedAndCreateAndRemoveWall()

        let result = engine.advanceDistance()
        if result.didScore {
            gameScoreForDistanceLabel?.text = "\(engine.score)"
            if let label = gameScoreForDistanceLabel {
                label.position = CGPoint(x: label.frame.size.width / 2,
                                         y: frame.size.height - 100 - label.frame.size.height)
            }
        }
        if result.shouldSpawnTool, let lastLine = walls.last, let wall = lastLine.first {
            createTool(toolX: wall.position.x + CGFloat(GameConstants.wallLeftAndRightDistance) / 2)
        }
    }

    /// Collision test shared by wall and tool checks. Matches
    /// `isCollision:withOeject:` — the player's effective hit-box is the centre
    /// 50% of its frame, intersected with the object's full frame.
    func isCollision(_ player: Player, with object: SKSpriteNode) -> Bool {
        GameEngine.isCollision(playerFrame: player.calculateAccumulatedFrame(),
                               objectFrame: object.calculateAccumulatedFrame())
    }
}
