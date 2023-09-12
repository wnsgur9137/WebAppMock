//
//  SceneDelegate.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/08/31.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    let appDIContainer = AppDIContainer()
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer()
        let rootViewController = mainSceneDIContainer.makeMainScene(navigationController: navigationController)
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
}

