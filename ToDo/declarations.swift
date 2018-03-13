//
//  declarations.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/10/31.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

extension String {
    func partialMatch(target: String) -> Bool {
        return self.lowercased(with: .current).contains(target.lowercased(with: .current))
    }
    
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}

extension UITableView {
    func setUp() {
        self.rowHeight = 60
        self.keyboardDismissMode = .interactive
        self.allowsSelectionDuringEditing = true
    }
    
    func deselectCell() {
        if let indexPathForSelectedRow = self.indexPathForSelectedRow {
            self.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func reload() {
        self.reloadData()
        self.tableFooterView = UIView()
    }
}

extension UISearchBar {
    func setUp() {
        self.enablesReturnKeyAutomatically = false
        self.autocapitalizationType = .none
    }
    
    func enable(_ bool: Bool) {
        if bool {
            self.isUserInteractionEnabled = true
            self.alpha = 1
            self.endEditing(true)
        } else {
            self.isUserInteractionEnabled = false
            self.alpha = 0.75
        }
    }
}

class variables {
    static let shared = variables()
    
    var isFromFileView = false
    
    var isFromListView = false
    
    var isFromMemoView = false
    
    var movingTaskName = ""
    
    var includingTasks = [String]()
    
    var condition: Condition = .month
}

enum Condition {
    case month
    case week
    case finished
}
