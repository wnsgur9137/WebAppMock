//
//  AppConfigurations.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/09/04.
//

import Foundation

final class AppConfiguration {
    lazy var webURL: String = {
        guard let webURL = Bundle.main.object(forInfoDictionaryKey: "WEB_URL") as? String else {
            fatalError("webURL must not be empty in plist")
        }
        return webURL
    }()
}
