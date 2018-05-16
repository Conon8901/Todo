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
        if let index = self.indexPathForSelectedRow {
            self.deselectRow(at: index, animated: true)
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
    
    func enable(_ isEnabled: Bool) {
        if isEnabled {
            self.isUserInteractionEnabled = true
            self.alpha = 1
            
            self.endEditing(true)
        } else {
            self.isUserInteractionEnabled = false
            self.alpha = 0.75
        }
    }
}

extension UIBarButtonItem {
    func hide(_ isHidden: Bool) {
        if isHidden {
            self.isEnabled = false
            self.tintColor = .clear
        } else {
            self.isEnabled = true
            self.tintColor = nil
        }
    }
}

// MARK: - class

class variables {
    static let shared = variables()
    
    var isFromNoteView = false
    var isFromMoveView = false
    
    var isSearched = false
    var searchText = ""
    
    var isFromTaskView = false
    
    var currentCategory = ""
    var currentTask = ""
    
    var movingTask = ""
    
    var includingTasks = [String]()
    
    var condition: Condition = .month
}

// MARK: - enum

enum Condition: Double {
    case month = 2592000
    case week = 604800
    case over = 0
}
