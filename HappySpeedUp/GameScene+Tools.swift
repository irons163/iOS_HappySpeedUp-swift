//
//  GameScene+Tools.swift
//  HappySpeedUp
//
//  Tool pickups: eating, recycling, spawning, scrolling, and the fly visuals.
//  (The numeric effects of eating a tool are handled by GameEngine.)
//

import SpriteKit

extension GameScene {

    func checkEatTool() {
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

    func checkRemoveTools() {
        var removeArray: [Tool] = []
        for tool in tools where tool.isNeedRemoveInstance() {
            tool.removeFromParent()
            removeArray.append(tool)
        }
        tools.removeAll { removed in removeArray.contains { $0 === removed } }
    }

    func createTool(toolX: CGFloat) {
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

    func moveTools(_ moveDistance: CGFloat) {
        let speedY = engine.speedY
        for tool in tools {
            tool.position = CGPoint(x: tool.position.x - moveDistance,
                                    y: tool.position.y - speedY)
        }
    }

    // MARK: - Fly visuals (numbers handled by GameEngine)

    func applyFlyVisual() {
        guard let player = player else { return }
        player.run(.scale(to: 2, duration: 2.0))

        let wing = SKSpriteNode(imageNamed: "wing")
        wing.size = CGSize(width: 75, height: 35)
        wing.position = CGPoint(x: 0, y: 10)
        wing.zPosition = 3
        player.addChild(wing)
    }

    func applyFlyResetVisual() {
        guard let player = player else { return }
        let scaleDown = SKAction.scale(to: 1, duration: 2.0)
        player.run(.sequence([scaleDown, .run { [weak self] in
            self?.engine.finishFlyReset()
            player.removeAllChildren()
        }]))
    }
}
