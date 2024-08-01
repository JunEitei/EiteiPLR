//
//  SceneDelegate.swift
//  Example-Cocoapods
//
//  Created by damao on 2024/7/10.
//

import UIKit
import EiteiPLR

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)

        // 把我的地址換成你自己的音樂倉庫地址
        window?.rootViewController = ViewController(baseURL: "https://api.github.com/repos/JunEitei/EiteiPLR/contents/Music")

        window?.makeKeyAndVisible()
    }

}
