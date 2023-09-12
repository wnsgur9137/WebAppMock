//
//  MainSceneDIContainer.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/09/04.
//

import UIKit

final class MainSceneDIContainer {
    struct Dependencies {
        let webURL: String
    }
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func makeMainScene(navigationController: UINavigationController) -> UINavigationController {
        return UINavigationController(rootViewController: makeHomeViewController())
    }
}

extension MainSceneDIContainer {
    func makeHomeUseCase() -> HomeUseCase {
        return DefaultHomeUseCase()
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return DefaultHomeViewModel(homeUseCase: makeHomeUseCase())
    }
    
    func makeHomeViewController() -> HomeViewController {
        return HomeViewController.create(with: makeHomeViewModel(), webURL: dependencies.webURL)
    }
}
