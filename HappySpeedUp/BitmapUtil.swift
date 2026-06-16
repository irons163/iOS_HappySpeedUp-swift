//
//  BitmapUtil.swift
//  HappySpeedUp
//
//  Swift port of BitmapUtil.{h,m}. Loads and sizes the textures used by the
//  game. The sizing maths is preserved exactly so it can be unit-tested.
//

import SpriteKit
import UIKit

final class BitmapUtil {

    // Tuning constants from the original initialiser.
    let playerWidthPercent: CGFloat = 2.5
    let toolWidthPercent: CGFloat = 4
    let fireballWidthPercent: CGFloat = 3

    let screenWidth: CGFloat = 300.0
    let screenHeight: CGFloat = 600.0

    let wallBitmap: SKTexture
    let wallSize: CGSize
    let speedupBitmap: SKTexture
    let speedupSize: CGSize
    let speeddownBitmap: SKTexture
    let speeddownSize: CGSize
    let flyBitmap: SKTexture
    let flySize: CGSize

    static let shared = BitmapUtil()

    private init() {
        let footbarWidth = screenWidth / 4
        let playerWidth = footbarWidth / playerWidthPercent

        wallBitmap = SKTexture(imageNamed: "f1-hd")
        wallSize = BitmapUtil.aspectSize(for: wallBitmap, width: playerWidth)

        speedupBitmap = SKTexture(imageNamed: "boots")
        speedupSize = BitmapUtil.aspectSize(for: speedupBitmap, width: playerWidth)

        speeddownBitmap = SKTexture(imageNamed: "bubble_1")
        speeddownSize = BitmapUtil.aspectSize(for: speeddownBitmap, width: playerWidth)

        flyBitmap = SKTexture(imageNamed: "wing")
        flySize = BitmapUtil.aspectSize(for: flyBitmap, width: playerWidth)
    }

    /// Computes a size that preserves the texture's aspect ratio for a given
    /// target width, truncating the height to an integer exactly as the
    /// Objective-C `(int)(...)` cast did.
    static func aspectSize(for texture: SKTexture, width: CGFloat) -> CGSize {
        let t = texture.size()
        let height = t.width > 0 ? CGFloat(Int(t.height / t.width * width)) : 0
        return CGSize(width: width, height: height)
    }
}
