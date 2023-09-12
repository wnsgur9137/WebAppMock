//
//  HomeUseCase.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/09/04.
//

import Foundation

protocol HomeUseCase {
    func checkNetworkConnected() -> Bool
}

final class DefaultHomeUseCase: HomeUseCase {
    func checkNetworkConnected() -> Bool {
        return Reachability.networkConnected()
    }
}
