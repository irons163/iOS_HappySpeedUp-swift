//
//  AppDelegate.swift
//  HappySpeedUp
//
//  Swift port of AppDelegate.{h,m} / main.m. Uses the classic single-window
//  storyboard launch flow (no scene delegate) to match the original app.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
}
