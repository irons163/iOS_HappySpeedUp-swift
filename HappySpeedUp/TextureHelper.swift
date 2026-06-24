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
        return pick(all, at: positions)
    }

    /// Core slicing routine. `SKTexture(rect:in:)` expects normalised (0–1)
    /// coordinates, hence the divisions by the sheet's pixel size.
    private static func slice(_ ssTexture: SKTexture,
                              source: CGRect,
                              rows rowNumberOfSprites: Int,
                              cols colNumberOfSprites: Int) -> [SKTexture] {
        let rects = frameRects(sheetSize: ssTexture.size(),
                               source: source,
                               rows: rowNumberOfSprites,
                               cols: colNumberOfSprites)
        return rects.map { SKTexture(rect: $0, in: ssTexture) }
    }

    /// Pure computation of the normalised (0–1) cutter rectangles for a sprite
    /// sheet of a given pixel size. Extracted so the slicing geometry — which
    /// is the tricky part ported from `TextureHelper.m` — can be unit-tested
    /// without a real texture.
    static func frameRects(sheetSize sheet: CGSize,
                           source: CGRect,
                           rows rowNumberOfSprites: Int,
                           cols colNumberOfSprites: Int) -> [CGRect] {
        guard sheet.width > 0, sheet.height > 0,
              rowNumberOfSprites > 0, colNumberOfSprites > 0 else { return [] }

        var rects: [CGRect] = []
        var sx = source.origin.x
        var sy = source.origin.y
        let sWidth = source.size.width
        let sHeight = source.size.height

        let total = rowNumberOfSprites * colNumberOfSprites
        for i in 0..<total {
            rects.append(CGRect(x: sx,
                                y: sy,
                                width: sWidth / sheet.width,
                                height: sHeight / sheet.height))
            sx += sWidth / sheet.width
            if (i + 1) % colNumberOfSprites == 0 {
                sx = source.origin.x
                sy += sHeight / sheet.height
            }
        }
        return rects
    }

    /// Returns the elements at `positions`, skipping any out-of-range indices.
    /// Mirrors the sequence selection in the original sprite-sheet helper.
    static func pick<T>(_ frames: [T], at positions: [Int]) -> [T] {
        positions.compactMap { frames.indices.contains($0) ? frames[$0] : nil }
    }
}
