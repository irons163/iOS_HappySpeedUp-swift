//
//  MyUtils.swift
//  HappySpeedUp
//
//  Swift port of MyUtils.{h,m}. A tiny static wrapper around a looping
//  AVAudioPlayer used for background music.
//

import AVFoundation
import Foundation

enum MyUtils {

    private static var backgroundMusicPlayer: AVAudioPlayer?

    /// Prepares (but does not start) a looping player for `filename`.
    static func preparePlayBackgroundMusic(_ filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Could not find file:\(filename)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            backgroundMusicPlayer = player
        } catch {
            print("Could not create audio player:\(error)")
        }
    }

    /// Prepares and immediately starts a looping player for `filename`.
    static func playBackgroundMusic(_ filename: String) {
        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else {
            print("Could not find file:\(filename)")
            return
        }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.prepareToPlay()
            player.play()
            backgroundMusicPlayer = player
        } catch {
            print("Could not create audio player:\(error)")
        }
    }

    static func backgroundMusicPlayerStop() {
        backgroundMusicPlayer?.stop()
    }

    static func backgroundMusicPlayerPause() {
        backgroundMusicPlayer?.pause()
    }

    static func backgroundMusicPlayerPlay() {
        backgroundMusicPlayer?.play()
    }

    static var isBackgroundMusicPlayerPlaying: Bool {
        backgroundMusicPlayer?.isPlaying ?? false
    }
}
