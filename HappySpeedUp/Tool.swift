//
//  Tool.swift
//  HappySpeedUp
//
//  Swift port of Tool.{h,m}. A pickup sprite carrying a `type`.
//

import SpriteKit

final class Tool: SKSpriteNode {

    /// The effect this tool grants. Backed by `Int` to mirror the original
    /// `@property int type;` and its `TOOL_*` constants.
    var type: Int = ToolType.speedUp.rawValue

    /// Convenience typed accessor.
    var toolType: ToolType {
        get { ToolType(rawValue: type) ?? .speedUp }
        set { type = newValue.rawValue }
    }

    /// True once this tool has scrolled below the bottom of the screen.
    func isNeedRemoveInstance() -> Bool {
        GameEngine.toolNeedsRemoval(atY: position.y)
    }
}
