//
//  CommonUtil.swift
//  HappySpeedUp
//
//  Swift port of CommonUtil.{h,m}. A shared singleton holding the current
//  screen dimensions. Kept as an SKSpriteNode subclass to match the original.
//

import SpriteKit

final class CommonUtil: SKSpriteNode {

    var screenHeight: CGFloat = 0
    var screenWidth: CGFloat = 0

    /// Shared singleton. `CommonUtil()` resolves to the inherited
    /// `SKSpriteNode()` initialiser since this subclass only adds
    /// default-valued stored properties.
    static let shared = CommonUtil()
}
