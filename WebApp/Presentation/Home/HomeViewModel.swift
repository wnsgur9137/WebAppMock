//
//  HomeViewModel.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/08/31.
//

import Foundation
import Combine

protocol HomeViewModelInput {
    func checkNetworkConnected()
}

protocol HomeViewModelOutput {
    var isOffline: PassthroughSubject<Bool, Never> { get }
}

protocol HomeViewModel: HomeViewModelInput, HomeViewModelOutput { }

final class DefaultHomeViewModel: HomeViewModel {
    private let useCase: HomeUseCase
    
    private(set) var isOffline: PassthroughSubject<Bool, Never> = PassthroughSubject()
    
    init(homeUseCase: HomeUseCase) {
        self.useCase = homeUseCase
    }
}

// MARK: - INPUT
extension DefaultHomeViewModel {
    func checkNetworkConnected() {
        guard useCase.checkNetworkConnected() else {
            isOffline.send(true)
            return
        }
        isOffline.send(false)
    }
}
