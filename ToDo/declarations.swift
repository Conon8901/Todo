//
//  declarations.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/10/31.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

// MARK: - extension

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    func partialMatch(_ target: String) -> Bool {
        return self.lowercased(with: .current).contains(target.lowercased(with: .current))
    }
    
    func characterExists() -> Bool {
        return !self.components(separatedBy: .whitespaces).joined().isEmpty
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

// MARK: - class

class variables {
    static let shared = variables()
    
    var isFromNoteViewController = false
    var isFromMoveViewController = false
    
    var currentCategory = ""
    var currentTask = ""
    
    var movingTask = ""
    
    var includingTasks = [String]()
    
    var condition: Condition = .month
}

// MARK: - enum

enum Condition {
    case month
    case week
    case over
}

enum PickRange: Double {
    case month = 2592000
    case week = 604800
    case over = 0
}
