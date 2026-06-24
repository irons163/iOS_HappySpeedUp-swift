//
//  GameScene+UI.swift
//  HappySpeedUp
//
//  Scene setup and chrome: initial game state, HUD score label, ready/tool
//  countdown timers, the player sprite, the leaderboard/music buttons, the ad
//  banner and the scrolling background.
//

import SpriteKit
import UIKit

extension GameScene {

    // MARK: - Initial setup

    func initGame() {
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

    func initGameScoreForDistanceLabel() {
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

    func createPlayer() {
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

    // MARK: - Ready / tool timers

    func initReadyTimer() {
        readyStep = 0
        theReadyTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                             target: self,
                                             selector: #selector(countReadyTimer),
                                             userInfo: nil,
                                             repeats: true)
    }

    @objc func countReadyTimer() {
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

    func initToolTimer() {
        readyStep = 0
        theToolTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                            target: self,
                                            selector: #selector(countToolTimer),
                                            userInfo: nil,
                                            repeats: true)
    }

    @objc func countToolTimer() {
        let wasFlying = engine.flyFlag
        let didReset = engine.tickToolTimer()
        if didReset && wasFlying {
            applyFlyResetVisual()
        }
    }

    // MARK: - Background

    func getBackground() {
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

    func moveBg() {
        let speedY = engine.speedY
        enumerateChildNodes(withName: "background") { node, _ in
            if node.position.y <= -node.frame.size.height {
                node.position = CGPoint(x: node.position.x,
                                        y: node.position.y + node.frame.size.height * 2)
            }
            node.position = CGPoint(x: node.position.x, y: node.position.y - speedY)
        }
    }
}
