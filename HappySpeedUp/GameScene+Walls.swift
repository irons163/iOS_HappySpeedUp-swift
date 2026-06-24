//
//  GameScene+Walls.swift
//  HappySpeedUp
//
//  Wall generation, scrolling, recycling and collision detection.
//

import SpriteKit

extension GameScene {

    func createInitWall() {
        let wallLeftX = 40
        let wallRightX = wallLeftX + GameConstants.wallLeftAndRightDistance
        var wallY = 0
        for _ in 0..<GameConstants.initialWallLineCount {
            createWallLine(leftX: wallLeftX, rightX: wallRightX, y: wallY, enableOffsetX: false)
            wallY += offsetY
        }
    }

    func createWallLine(leftX: Int, rightX: Int, y: Int, enableOffsetX: Bool) {
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

    func doWallMoveAndCollisionDetectedAndCreateAndRemoveWall() {
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
}
