//
//  AppDIContainer.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/09/04.
//

import Foundation

final class AppDIContainer {
    let appConfiguration = AppConfiguration()
    let isTestMode = true
    
    lazy var webURL: String = {
        let webURL = self.isTestMode ? appConfiguration.localWebURL : appConfiguration.webURL
        return webURL
    }()
    
    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        let dependencies = MainSceneDIContainer.Dependencies(webURL: webURL)
        return MainSceneDIContainer(dependencies: dependencies)
    }
}
