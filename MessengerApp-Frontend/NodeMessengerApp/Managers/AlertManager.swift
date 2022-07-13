//
//  File.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 21/04/2022.
//

import Foundation
import UIKit


class AlertManager {
    
    static let shared = AlertManager()
    
    public func showErrorAlert(vc: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
}
