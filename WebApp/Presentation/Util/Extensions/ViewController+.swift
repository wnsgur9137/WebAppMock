//
//  ViewController+.swift
//  WebApp
//
//  Created by JunHyeok Lee on 2023/09/01.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, description: String, handler: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: handler)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: completion)
        return
    }
    
    func showAlertWithOK(title: String, description: String, confirmHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: description, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: cancelHandler)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: confirmHandler)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: completion)
        return
    }
}
