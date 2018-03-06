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
}

class variables {
    static let shared = variables()
    
    var isFromFileView = false
    
    var isFromListView = false
    
    var isFromMemoView = false
    
    var movingFileName = ""
    
    var includingFiles = [String]()
    
    var condition = ""
    
    var dateArray = [String]()
}
