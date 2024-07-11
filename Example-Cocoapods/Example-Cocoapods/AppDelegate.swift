//
//  AppDelegate.swift
//  Example-Cocoapods
//
//  Created by damao on 2024/7/1.
//

import UIKit
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 在背景執行緒中配置音頻會話，避免在主執行緒進行I/O操作
        DispatchQueue.global(qos: .background).async {
            do {
                // 設置音頻會話類別和模式，並允許與其他音頻混合
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
                // 啟用音頻會話
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                // 如果配置失敗，打印錯誤訊息
                print("配置AVAudioSession失敗: \(error.localizedDescription)")
            }
        }

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

