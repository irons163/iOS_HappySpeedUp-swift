//
//  TextureHelper.swift
//  HappySpeedUp
//
//  Swift port of TextureHelper.{h,m}. Slices a sprite-sheet image into an
//  array of SKTextures, optionally returning only a requested sub-sequence.
//

import SpriteKit
import UIKit

enum TextureHelper {

    /// Slices `spriteSheet` into `rows * cols` textures over `source`.
    static func textures(spriteSheetNamed spriteSheet: String,
                         sourceRect source: CGRect,
                         rows rowNumberOfSprites: Int,
                         cols colNumberOfSprites: Int) -> [SKTexture] {
        let ssTexture = SKTexture(imageNamed: spriteSheet)
        ssTexture.filteringMode = .nearest
        return slice(ssTexture,
                     source: source,
                     rows: rowNumberOfSprites,
                     cols: colNumberOfSprites)
    }

    /// Slices `spriteSheet` (loaded from the bundle as a `.png`) and returns
    /// only the frames at the indices listed in `sequence`.
    static func textures(spriteSheetNamed spriteSheet: String,
                         sourceRect source: CGRect,
                         rows rowNumberOfSprites: Int,
                         cols colNumberOfSprites: Int,
                         sequence positions: [Int]) -> [SKTexture] {
        let ssTexture: SKTexture
        if let path = Bundle.main.path(forResource: spriteSheet, ofType: "png"),
           let image = UIImage(contentsOfFile: path) {
            ssTexture = SKTexture(image: image)
        } else {
            ssTexture = SKTexture(imageNamed: spriteSheet)
        }
        ssTexture.filteringMode = .nearest

        let all = slice(ssTexture,
                        source: source,
                        rows: rowNumberOfSprites,
                        cols: colNumberOfSprites)
        return positions.compactMap { all.indices.contains($0) ? all[$0] : nil }
    }

    /// Core slicing routine. `SKTexture(rect:in:)` expects normalised (0–1)
    /// coordinates, hence the divisions by the sheet's pixel size.
    private static func slice(_ ssTexture: SKTexture,
                              source: CGRect,
                              rows rowNumberOfSprites: Int,
                              cols colNumberOfSprites: Int) -> [SKTexture] {
        var frames: [SKTexture] = []
        let sheet = ssTexture.size()
        guard sheet.width > 0, sheet.height > 0 else { return frames }

        var sx = source.origin.x
        var sy = source.origin.y
        let sWidth = source.size.width
        let sHeight = source.size.height

        let total = rowNumberOfSprites * colNumberOfSprites
        for i in 0..<total {
            let cutter = CGRect(x: sx,
                                y: sy,
                                width: sWidth / sheet.width,
                                height: sHeight / sheet.height)
            frames.append(SKTexture(rect: cutter, in: ssTexture))

            sx += sWidth / sheet.width
            if (i + 1) % colNumberOfSprites == 0 {
                sx = source.origin.x
                sy += sHeight / sheet.height
            }
        }
        return frames
    }
}
