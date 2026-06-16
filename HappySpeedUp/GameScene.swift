//
//  GameScene.swift
//  HappySpeedUp
//
//  Swift port of GameScene.{h,m}. The numeric game state (speeds, score,
//  tool timers, collision rules) lives in `GameEngine`; this class owns the
//  SpriteKit nodes and drives the engine from the run loop.
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

    // MARK: - Nodes & helpers

    private var bitmapUtil: BitmapUtil = .shared
    private var offsetX: Int = 0
    private var offsetY: Int = 0

    private var backgroundNode: SKSpriteNode?
    private var backgroundNode2: SKSpriteNode?
    private var backgroundMovePointsPerSec: CGFloat = 0

    private var gameScoreForDistanceLabel: SKLabelNode?

    private var readyStep: Int = 0
    private var theReadyTimer: Timer?
    private var theToolTimer: Timer?
    private var readyLabel: SKLabelNode?

    private var rankBtn: SKSpriteNode?
    private var myAdView: MyADView?

    private var musicBtnTextures: [SKTexture] = []
    private var musicBtn: SKSpriteNode?

    private var walls: [[Wall]] = []
    private var tools: [Tool] = []
    private var player: Player?

    // MARK: - Setup

    private func initGame() {
        readyStep = 0

        CommonUtil.shared.screenHeight = frame.size.height
        CommonUtil.shared.screenWidth = frame.size.width
        bitmapUtil = BitmapUtil.shared
        offsetX = Int(bitmapUtil.wallSize.width)
        offsetY = Int(bitmapUtil.wallSize.height)

        let ready = SKLabelNode(fontNamed: "Chalkduster")
        ready.zPosition = 3
        ready.text = ""
        ready.fontSize = 80
        ready.fontColor = .red
        ready.position = CGPoint(x: frame.size.width / 2 - ready.frame.size.width / 2,
                                 y: frame.size.height / 2)
        addChild(ready)
        readyLabel = ready

        let rank = SKSpriteNode(imageNamed: "btnL_GameCenter-hd")
        rank.size = CGSize(width: 42, height: 42)
        rank.anchorPoint = CGPoint(x: 0, y: 0)
        rank.position = CGPoint(x: frame.size.width - rank.size.width, y: frame.size.height / 2)
        rank.zPosition = 1
        addChild(rank)
        rankBtn = rank

        musicBtnTextures = [
            SKTexture(imageNamed: "btn_Music-hd"),
            SKTexture(imageNamed: "btn_Music_Select-hd"),
        ]

        let music = SKSpriteNode(imageNamed: "btn_Music-hd")
        music.size = CGSize(width: 42, height: 42)
        music.anchorPoint = CGPoint(x: 0, y: 0)
        music.position = CGPoint(x: frame.size.width - music.size.width,
                                 y: frame.size.height / 2 - 42)
        music.zPosition = 1
        addChild(music)
        musicBtn = music

        let musics = ["am_white.mp3", "biai.mp3", "cafe.mp3", "deformation.mp3"]
        let index = Int(arc4random_uniform(4))
        MyUtils.preparePlayBackgroundMusic(musics[index])

        let isPlayMusicObject = UserDefaults.standard.object(forKey: "isPlayMusic")
        let isPlayMusic = (isPlayMusicObject as? Bool) ?? true

        if isPlayMusic {
            MyUtils.backgroundMusicPlayerPlay()
            music.texture = musicBtnTextures[0]
        } else {
            MyUtils.backgroundMusicPlayerPause()
            music.texture = musicBtnTextures[1]
        }

        let ad = MyADView(texture: nil, color: .clear, size: .zero)
        ad.size = CGSize(width: frame.size.width, height: frame.size.width / 5.0)
        ad.position = CGPoint(x: frame.size.width / 2, y: 0)
        ad.startAd()
        ad.zPosition = 1
        ad.anchorPoint = CGPoint(x: 0.5, y: 0)
        addChild(ad)
        myAdView = ad
    }

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

    // MARK: - Ready / tool timers

    private func initReadyTimer() {
        readyStep = 0
        theReadyTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(countReadyTimer),
                                             userInfo: nil,
                                             repeats: true)
    }

    @objc private func countReadyTimer() {
        if readyStep == 0 {
            readyLabel?.text = "READY"
            readyLabel?.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        } else if readyStep == 5 {
            readyLabel?.isHidden = true
            theReadyTimer?.invalidate()
            engine.readyFlag = false
            return
        } else {
            readyLabel?.text = "\(4 - readyStep)"
            readyLabel?.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        }
        readyStep += 1
    }

    private func initToolTimer() {
        readyStep = 0
        theToolTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                            target: self,
                                            selector: #selector(countToolTimer),
                                            userInfo: nil,
                                            repeats: true)
    }

    @objc private func countToolTimer() {
        let wasFlying = engine.flyFlag
        let didReset = engine.tickToolTimer()
        if didReset && wasFlying {
            applyFlyResetVisual()
        }
    }

    // MARK: - Touch

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)

            if let rankBtn = rankBtn,
               rankBtn.calculateAccumulatedFrame.contains(location) {
                gameDelegate?.showRankView()
            } else if let musicBtn = musicBtn,
                      musicBtn.calculateAccumulatedFrame.contains(location) {
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

    // MARK: - Walls

    private func createInitWall() {
        let wallLeftX = 40
        let wallRightX = wallLeftX + GameConstants.wallLeftAndRightDistance
        var wallY = 0
        for _ in 0..<GameConstants.initialWallLineCount {
            createWallLine(leftX: wallLeftX, rightX: wallRightX, y: wallY, enableOffsetX: false)
            wallY += offsetY
        }
    }

    private func createWallLine(leftX: Int, rightX: Int, y: Int, enableOffsetX: Bool) {
        var wallLeftX = leftX
        var wallRightX = rightX
        var wallY = y

        if enableOffsetX {
            if arc4random_uniform(2) == 0 {
                offsetX = -offsetX
            }
            wallLeftX += offsetX
            wallRightX += offsetX
        }

        if CGFloat(wallY) >= CommonUtil.shared.screenHeight + CGFloat(offsetY) { return }

        wallY += offsetY

        let wallLeft = Wall(texture: bitmapUtil.wallBitmap)
        wallLeft.size = bitmapUtil.wallSize
        wallLeft.position = CGPoint(x: wallLeftX, y: wallY)
        wallLeft.xScale = -1

        let wallRight = Wall(texture: bitmapUtil.wallBitmap)
        wallRight.size = bitmapUtil.wallSize
        wallRight.position = CGPoint(x: wallRightX, y: wallY)

        addChild(wallLeft)
        addChild(wallRight)
        walls.append([wallLeft, wallRight])
    }

    private func initGameScoreForDistanceLabel() {
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "0"
        label.fontSize = 30
        label.fontColor = SKColor(red: 0.15, green: 0.15, blue: 0.7, alpha: 1.0)
        label.position = CGPoint(x: label.frame.size.width / 2,
                                 y: frame.size.height - 100 - label.frame.size.height)
        label.zPosition = 5
        addChild(label)
        gameScoreForDistanceLabel = label
    }

    private func createPlayer() {
        let p = Player(imageNamed: "yellow_point")
        let array = TextureHelper.textures(spriteSheetNamed: "hamster",
                                           sourceRect: CGRect(x: 0, y: 0, width: 192, height: 200),
                                           rows: 2,
                                           cols: 7,
                                           sequence: [7, 8])
        if let first = array.first { p.texture = first }
        if !array.isEmpty {
            p.run(.repeatForever(.animate(with: array, timePerFrame: 0.2)))
        }
        p.size = CGSize(width: 35, height: 35)
        p.position = CGPoint(x: GameConstants.playerStartX, y: GameConstants.playerStartY)
        p.zPosition = 2
        addChild(p)
        player = p
    }

    // MARK: - Movement

    private func move() {
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

    private func isCollision(_ player: Player, with object: SKSpriteNode) -> Bool {
        GameEngine.isCollision(playerFrame: player.calculateAccumulatedFrame,
                               objectFrame: object.calculateAccumulatedFrame)
    }

    private func doWallMoveAndCollisionDetectedAndCreateAndRemoveWall() {
        guard let player = player else { return }

        var collision = false
        var needCreate = false
        var needRemove = false
        let firstCarPosition = 0
        let lastCatPosition = walls.count - 1
        var lastLeftWall: Wall?

        for wallLinePosition in 0..<walls.count {
            var isChecked = false
            for wall in walls[wallLinePosition] {
                wall.move(engine.speedY)
                if !isChecked {
                    isChecked = true
                    if wallLinePosition == lastCatPosition {
                        needCreate = wall.isNeedCreateNewInstance()
                        lastLeftWall = wall
                    }
                    if wallLinePosition == firstCarPosition {
                        needRemove = wall.isNeedRemoveInstance()
                    }
                }
                if !collision {
                    collision = isCollision(player, with: wall)
                }
            }
        }

        if needCreate, let lastLeftWall = lastLeftWall {
            let wallLeftX = Int(lastLeftWall.position.x)
            let wallRightX = wallLeftX + GameConstants.wallLeftAndRightDistance
            let wallY = Int(lastLeftWall.position.y)
            createWallLine(leftX: wallLeftX, rightX: wallRightX, y: wallY, enableOffsetX: true)
        }
        if needRemove, !walls.isEmpty {
            let line = walls.remove(at: firstCarPosition)
            for wall in line { wall.removeFromParent() }
        }

        if collision {
            engine.registerCollision()
            player.removeAllActions()
            GameCenterUtil.shared.reportScore(engine.score, forCategory: "com.irons.HappySpeedUp")
            gameDelegate?.showGameOver()
            myAdView?.close()
        }
    }

    // MARK: - Background

    private func getBackground() {
        let node = SKSpriteNode(texture: nil)
        node.zPosition = -1
        node.anchorPoint = .zero

        let bg1 = SKSpriteNode(imageNamed: "bg01_green")
        bg1.anchorPoint = .zero
        bg1.size = frame.size
        bg1.position = .zero
        node.addChild(bg1)

        let bg2 = SKSpriteNode(imageNamed: "bg01_green")
        bg2.anchorPoint = .zero
        bg2.size = frame.size
        bg2.position = CGPoint(x: 0, y: bg1.size.height)
        node.addChild(bg2)

        node.size = CGSize(width: bg1.size.width, height: bg1.size.height + bg2.size.height)
        node.name = "background"
        backgroundNode = node

        let node2 = node.copy() as? SKSpriteNode
        node2?.position = CGPoint(x: 0, y: node.size.height)
        if let node2 = node2 {
            addChild(node2)
            backgroundNode2 = node2
        }
    }

    private func moveBg() {
        let speedY = engine.speedY
        enumerateChildNodes(withName: "background") { node, _ in
            if node.position.y <= -node.frame.size.height {
                node.position = CGPoint(x: node.position.x,
                                        y: node.position.y + node.frame.size.height * 2)
            }
            node.position = CGPoint(x: node.position.x, y: node.position.y - speedY)
        }
    }

    // MARK: - Tools

    private func checkEatTool() {
        guard let player = player else { return }

        var eaten: Tool?
        for tool in tools {
            if isCollision(player, with: tool) {
                eaten = tool
                break
            }
        }

        if let tool = eaten {
            tools.removeAll { $0 === tool }
            tool.removeFromParent()
            engine.eatTool(tool.toolType)
            if tool.toolType == .fly {
                applyFlyVisual()
            }
        }
    }

    private func checkRemoveTools() {
        var removeArray: [Tool] = []
        for tool in tools where tool.isNeedRemoveInstance() {
            tool.removeFromParent()
            removeArray.append(tool)
        }
        tools.removeAll { removed in removeArray.contains { $0 === removed } }
    }

    private func createTool(toolX: CGFloat) {
        let type = ToolType.from(spawnRoll: Int(arc4random_uniform(5)))
        let tool: Tool
        switch type {
        case .speedUp:
            tool = Tool(texture: bitmapUtil.speedupBitmap)
            tool.size = bitmapUtil.speedupSize
        case .speedDown:
            tool = Tool(texture: bitmapUtil.speeddownBitmap)
            tool.size = bitmapUtil.speeddownSize
        case .fly:
            tool = Tool(texture: bitmapUtil.flyBitmap)
            tool.size = bitmapUtil.flySize
        }
        tool.toolType = type
        tool.position = CGPoint(x: toolX, y: frame.size.height)
        addChild(tool)
        tools.append(tool)
    }

    private func moveTools(_ moveDistance: CGFloat) {
        let speedY = engine.speedY
        for tool in tools {
            tool.position = CGPoint(x: tool.position.x - moveDistance,
                                    y: tool.position.y - speedY)
        }
    }

    // MARK: - Fly visuals (numbers handled by GameEngine)

    private func applyFlyVisual() {
        guard let player = player else { return }
        player.run(.scale(to: 2, duration: 2.0))

        let wing = SKSpriteNode(imageNamed: "wing")
        wing.size = CGSize(width: 75, height: 35)
        wing.position = CGPoint(x: 0, y: 10)
        wing.zPosition = 3
        player.addChild(wing)
    }

    private func applyFlyResetVisual() {
        guard let player = player else { return }
        let scaleDown = SKAction.scale(to: 1, duration: 2.0)
        player.run(.sequence([scaleDown, .run { [weak self] in
            self?.engine.finishFlyReset()
            player.removeAllChildren()
        }]))
    }
}
