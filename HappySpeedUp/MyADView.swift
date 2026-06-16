//
//  MyADView.swift
//  HappySpeedUp
//
//  Swift port of MyADView.{h,m}. A self-rotating house-ad banner that cycles
//  through promo images and opens the App Store on tap.
//

import SpriteKit
import UIKit

final class MyADView: SKSpriteNode {

    private var ads: [SKTexture] = []
    private var adsUrl: [String] = []
    private var adIndex: Int = 0
    private var button: SKSpriteNode?
    private var timer: Timer?

    func startAd() {
        let catAdImageName = arc4random_uniform(2) == 0
            ? "unlimited_cat_world_ad"
            : "UnlimitedCatWorld_ad"

        ads = [
            SKTexture(imageNamed: "ad1.jpg"),
            SKTexture(imageNamed: NSLocalizedString("cat_shoot_ad", comment: "")),
            SKTexture(imageNamed: "2048_ad"),
            SKTexture(imageNamed: "Shoot_Learning_ad"),
            SKTexture(imageNamed: "cute_dudge_ad"),
            SKTexture(imageNamed: catAdImageName),
            SKTexture(imageNamed: "crazy_split_ad"),
            SKTexture(imageNamed: "HappyDownStages_AD"),
        ]

        adsUrl = [
            "http://itunes.apple.com/us/app/good-sleeper-counting-sheep/id998186214?l=zh&ls=1&mt=8",
            "http://itunes.apple.com/us/app/attack-on-giant-cat/id1000152033?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/2048-chinese-zodiac/id1024333772?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/shoot-learning-math/id1025414483?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/cute-dodge/id1018590182?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/unlimited-cat-world/id1000573724?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/crazy-split/id1038958249?l=zh&ls=1&mt=8",
            "https://itunes.apple.com/us/app/adventure-happy-down-stages/id1035092790?l=zh&ls=1&mt=8",
        ]

        adIndex = 0
        texture = ads[adIndex]

        timer = Timer.scheduledTimer(timeInterval: 2.0,
                                     target: self,
                                     selector: #selector(changeAd),
                                     userInfo: nil,
                                     repeats: true)

        let closeButton = SKSpriteNode(imageNamed: "btn_Close-hd")
        closeButton.size = CGSize(width: 30, height: 30)
        closeButton.position = CGPoint(x: size.width / 2 - closeButton.size.width,
                                       y: size.height - closeButton.size.height)
        closeButton.anchorPoint = CGPoint(x: 0, y: 0)
        closeButton.zPosition = 5
        addChild(closeButton)
        button = closeButton
    }

    @objc func changeAd() {
        adIndex += 1
        if adIndex < ads.count {
            texture = ads[adIndex]
        } else {
            adIndex = 0
            texture = ads.isEmpty ? nil : ads[adIndex]
        }
    }

    func doClick() {
        guard adIndex < adsUrl.count, let url = URL(string: adsUrl[adIndex]) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isHidden { return }
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if let button = button, button.contains(location) {
            isHidden = true
        } else if location.y < size.height {
            doClick()
        }
    }

    func close() {
        timer?.invalidate()
        timer = nil
    }
}
