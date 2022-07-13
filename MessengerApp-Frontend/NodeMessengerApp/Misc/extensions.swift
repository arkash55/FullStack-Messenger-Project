//
//  extensions.swift
//  NodeMessengerApp
//
//  Created by Arkash Vijayakumar on 14/04/2022.
//

import Foundation
import UIKit



extension UITextField {
    
    func addUnderline() {
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 2)
        underLine.backgroundColor = UIColor.label.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(underLine)
    }
    
    func addGreyUnderline() {
        let underLine = CALayer()
        underLine.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.size.width, height: 2)
        underLine.backgroundColor = UIColor.secondaryLabel.cgColor
        self.borderStyle = .none
        self.layer.addSublayer(underLine)
    }

}



extension Collection where Element: Equatable {
    /// Returns the second index where the specified value appears in the collection.
    func secondIndex(of element: Element) -> Index? {
        guard let index = firstIndex(of: element) else { return nil }
        return self[self.index(after: index)...].firstIndex(of: element)
    }
}
