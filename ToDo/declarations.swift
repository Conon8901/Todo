//
//  declarations.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/10/31.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

extension UITableView {
    func scroll(x: CGFloat = 0, y: CGFloat) {
        let offset = CGPoint(x: Int(x), y: Int(y))
        setContentOffset(offset, animated: true)
    }
    
    func setUp() {
        self.rowHeight = 60
        self.keyboardDismissMode = .interactive
        self.allowsSelectionDuringEditing = true
    }
}

extension UISearchBar {
    func setUp() {
        self.enablesReturnKeyAutomatically = false
        self.autocapitalizationType = .none
        
        let partial = NSLocalizedString("SCOPE_PARTIAL", comment: "")
        let exact = NSLocalizedString("SCOPE_EXACT", comment: "")
        
        self.scopeButtonTitles = [partial, exact]
    }
}

extension UITextView {
    func setUp() {
        self.text = ""
        self.layer.borderColor = UIColor(red: 205/255, green: 205/255, blue: 205/255, alpha: 1.0).cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.autocapitalizationType = .none
    }
}
