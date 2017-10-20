//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    var allRemoveButton: UIBarButtonItem?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var saveData = UserDefaults.standard
    
    var filesDict = [String: [String]]()
    var searchArray = [String]()
    
    var openedFolder = ""
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        openedFolder = saveData.object(forKey: "@folderName") as! String
        
        searchArray = filesDict[openedFolder]!
        
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.autocapitalizationType = .none
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        let partial = NSLocalizedString("部分", comment: "")
        let exact = NSLocalizedString("完全", comment: "")
        let forward = NSLocalizedString("前方", comment: "")
        let backward = NSLocalizedString("後方", comment: "")
        
        searchBar.scopeButtonTitles = [partial, exact, forward, backward]
        
        editButton.title = NSLocalizedString("編集", comment: "")
        
        allRemoveButton?.title = NSLocalizedString("全削除", comment: "")
        allRemoveButton?.isEnabled = true
        allRemoveButton?.tintColor = UIColor(white: 1, alpha: 1)
        
        allRemoveButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(FileViewController.allRemove))
        
        self.navigationItem.leftBarButtonItem = nil
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.putCheckmark))
        table.addGestureRecognizer(longPressRecognizer)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: openedFolder, style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = openedFolder
        
        if appDelegate.isFromListView {
            filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
            
            appDelegate.isFromListView = false
        }
        
        checkIsArrayEmpty()
        
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text!.isEmpty {
            return filesDict[openedFolder]!.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        var fileName = ""
        var key = ""
        
        if searchBar.text!.isEmpty {
            fileName = filesDict[openedFolder]![indexPath.row]
            
            key = openedFolder + "@" + fileName
            
            cell?.textLabel?.text = fileName
            
            if let subtitle = saveData.object(forKey: key + "@memo") as! String? {
                cell?.detailTextLabel?.text = subtitle
            }
            
            if let isChecked = saveData.object(forKey: key + "@check") as! Bool? {
                if isChecked {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
            }
        } else {
            fileName = searchArray[indexPath.row]
            
            key = openedFolder + "@" + fileName
            
            cell?.textLabel?.text = fileName
            
            if let subtitle = saveData.object(forKey: key + "@memo") as! String? {
                cell?.detailTextLabel?.text = subtitle
            }
            
            if let isChecked = saveData.object(forKey: key + "@check") as! Bool? {
                if isChecked {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
            }
        }
        
        cell?.textLabel?.text = fileName
        
        if let subtitle = saveData.object(forKey: key + "@memo") as! String? {
            cell?.detailTextLabel?.text = subtitle
        }
        
        if let isChecked = saveData.object(forKey: key + "@check") as! Bool? {
            if isChecked {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            let alert = UIAlertController(
                title: NSLocalizedString("名称変更", comment: ""),
                message: NSLocalizedString("タイトル入力", comment: ""),
                preferredStyle: .alert)
            
            let changeAction = UIAlertAction(title: NSLocalizedString("変更", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as UITextField
                
                let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
                
                if !isBlank {
                    if self.filesDict[self.openedFolder]?.index(of: textField.text!) == nil {
                        if !textField.text!.contains("@") {
                            if self.searchBar.text!.isEmpty {
                                let formerKey = self.openedFolder + "@" + self.filesDict[self.openedFolder]![indexPath.row]
                                let latterKey = self.openedFolder + "@" + textField.text!
                                
                                self.resaveMemo(ex: formerKey, post: latterKey)
                                
                                self.filesDict[self.openedFolder]?[indexPath.row] = textField.text!
                            } else {
                                let fileName = self.searchArray[indexPath.row]
                                
                                let formerKey = self.openedFolder + "@" + self.searchArray[indexPath.row]
                                let latterKey = self.openedFolder + "@" + textField.text!
                                
                                self.resaveMemo(ex: formerKey, post: latterKey)
                                
                                self.searchArray[indexPath.row] = textField.text!
                                
                                let index = self.filesDict[self.openedFolder]?.index(of: fileName)
                                self.filesDict[self.openedFolder]?[index!] = textField.text!
                                
                                self.showSearchResult()
                            }
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            
                            self.table.reloadData()
                        } else {
                            self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                            
                            self.deselectCell()
                        }
                    } else {
                        if textField.text != self.filesDict[self.openedFolder]?[indexPath.row] {
                            self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                        }
                        
                        self.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                    
                    self.deselectCell()
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.deselectCell()
            }
            
            alert.addTextField { (textField: UITextField!) -> Void in
                if self.searchBar.text!.isEmpty {
                    textField.text = self.filesDict[self.openedFolder]?[indexPath.row]
                } else {
                    textField.text = self.searchArray[indexPath.row]
                }
                
                textField.textAlignment = .left
            }
            
            alert.addAction(cancelAction)
            alert.addAction(changeAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            if searchBar.text!.isEmpty {
                saveData.set(filesDict[openedFolder]![indexPath.row], forKey: "@fileName")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@fileName")
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Memo") as! MemoViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("削除", comment: "")) { (action, index) -> Void in
            if self.searchBar.text!.isEmpty {
                let key = self.openedFolder + "@" + self.filesDict[self.openedFolder]![indexPath.row]
                self.removeAllObject(key: key)
                
                self.filesDict[self.openedFolder]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            } else {
                let key = self.openedFolder + "@" + self.searchArray[indexPath.row]
                self.removeAllObject(key: key)
                
                self.filesDict[self.openedFolder]?.remove(at: self.filesDict[self.openedFolder]!.index(of: self.searchArray[indexPath.row])!)
                self.searchArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            
            if self.filesDict[self.openedFolder]!.count < 11 {
                let location = CGPoint(x: 0, y: -64)
                self.table.setContentOffset(location, animated: true)
            }
            
            self.saveData.set(self.filesDict, forKey: "@dictData")
            
            self.checkIsArrayEmpty()
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("移動", comment: "")) { (action, index) -> Void in
            if self.searchBar.text!.isEmpty {
                self.appDelegate.movingFileName = self.filesDict[self.openedFolder]![indexPath.row]
            } else {
                self.appDelegate.movingFileName = self.searchArray[indexPath.row]
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "List") as! ListViewController
            self.present(nextView, animated: true)
        }
        
        moveButton.backgroundColor = .lightGray
     
        return [deleteButton, moveButton]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFile = filesDict[openedFolder]?[sourceIndexPath.row]
        
        filesDict[openedFolder]?.remove(at: sourceIndexPath.row)
        filesDict[openedFolder]?.insert(movingFile!, at: destinationIndexPath.row)
        
        saveData.set(filesDict, forKey: "@dictData")
        
        table.reloadData()
    }
    
    @IBAction func add() {
        let alert = UIAlertController(
            title: NSLocalizedString("追加", comment: ""),
            message: NSLocalizedString("タイトル入力", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
                if self.filesDict[self.openedFolder]?.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.filesDict[self.openedFolder]!.append(textField.text!)
                        
                        let key = self.openedFolder + "@" + textField.text!
                        
                        self.saveData.set("", forKey: key + "@memo")
                        self.saveData.set(false, forKey: key + "@ison")
                        self.saveData.set(false, forKey: key + "@check")
                        
                        if self.searchBar.text!.isEmpty {
                            if self.filesDict[self.openedFolder]!.count >= 11 {
                                let location = CGPoint(x: 0, y: self.table.contentSize.height - self.table.frame.height)
                                self.table.setContentOffset(location, animated: true)
                            }
                        } else {
                            if self.searchArray.count >= 11 {
                                let location = CGPoint(x: 0, y: self.table.contentSize.height - self.table.frame.height)
                                self.table.setContentOffset(location, animated: true)
                            }
                            
                            self.showSearchResult()
                        }
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        self.checkIsArrayEmpty()
                        
                        self.table.reloadData()
                    } else {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                    
                    self.deselectCell()
                }
            } else {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                
                self.deselectCell()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func putCheckmark(recognizer: UILongPressGestureRecognizer) {
        let indexPath = table.indexPathForRow(at: recognizer.location(in: table))
        let cell = table.cellForRow(at:indexPath!)
        
        if indexPath != nil {
            if recognizer.state == .began {
                if cell?.accessoryType == .none {
                    cell?.accessoryType = .checkmark
                    
                    if searchBar.text!.isEmpty {
                        saveData.set(true, forKey: openedFolder + "@" + filesDict[openedFolder]![indexPath!.row] + "@check")
                    } else {
                        saveData.set(true, forKey: openedFolder + "@" + searchArray[indexPath!.row] + "@check")
                    }
                } else {
                    cell?.accessoryType = .none
                    
                    if searchBar.text!.isEmpty {
                        saveData.set(false, forKey: openedFolder + "@" + filesDict[openedFolder]![indexPath!.row] + "@check")
                    } else {
                        saveData.set(false, forKey: openedFolder + "@" + searchArray[indexPath!.row] + "@check")
                    }
                }
            }
        }
    }
    
    @IBAction func tapEdit() {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            
            editButton.title = NSLocalizedString("編集", comment: "")
            
            self.navigationItem.leftBarButtonItem = nil
            
            navigationItem.hidesBackButton = false
            
            if filesDict[openedFolder]!.isEmpty {
                editButton.isEnabled = false
            }
            
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.putCheckmark))
            table.addGestureRecognizer(longPressRecognizer)
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            editButton.title = NSLocalizedString("完了", comment: "")
            
            navigationItem.hidesBackButton = true
            
            self.navigationItem.leftBarButtonItem = allRemoveButton
            
            table.gestureRecognizers?.removeAll()
        }
    }
    
    @objc func allRemove() {
        let alert = UIAlertController(
            title: NSLocalizedString("全削除", comment: ""),
            message: NSLocalizedString("本当によろしいですか？\nこのフォルダの全ファイルを削除します", comment: ""),
            preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("削除", comment: ""), style: .destructive) { (action: UIAlertAction!) -> Void in
            let folder = self.filesDict[self.openedFolder]!
            
            if !folder.isEmpty {
                for fileName in folder {
                    let key = self.openedFolder + "@" + fileName
                    self.removeAllObject(key: key)
                }
                
                self.filesDict[self.openedFolder] = []
                self.searchArray = []
                
                self.editButton.isEnabled = false
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                
                self.table.reloadData()
                
                self.editButton.isEnabled = true
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FileViewController.closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        self.view.gestureRecognizers?.removeAll()
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            searchArray.removeAll()
            searchArray = filesDict[openedFolder]!
            
            table.reloadData()
        } else {
            showSearchResult()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if !searchBar.text!.isEmpty {
            showSearchResult()
            
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        table.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if table.contentOffset.y < -64 {
            searchBar.endEditing(true)
        }
    }
    
    @objc func closeKeyboard() {
        searchBar.endEditing(true)
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("エラー", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkIsArrayEmpty() {
        if filesDict[openedFolder]!.isEmpty {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
    
    func deselectCell() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            searchArray = filesDict[openedFolder]!.filter {
                $0.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current))
            }
        case 1:
            searchArray = filesDict[openedFolder]!.filter {
                $0.lowercased(with: .current) == searchBar.text!.lowercased(with: .current)
            }
        case 2:
            searchArray = filesDict[openedFolder]!.filter {
                $0.lowercased(with: .current).hasPrefix(searchBar.text!.lowercased(with: .current))
            }
        case 3:
            searchArray = filesDict[openedFolder]!.filter {
                $0.lowercased(with: .current).hasSuffix(searchBar.text!.lowercased(with: .current))
            }
        default:
            break
        }
        
        table.reloadData()
    }
    
    func resaveMemo(ex: String, post: String) {
        let savedMemoText = self.saveData.object(forKey: ex + "@memo") as! String
        let isShownParts = self.saveData.object(forKey: ex + "@ison") as! Bool
        let savedDate = self.saveData.object(forKey: ex + "@date") as! Date?
        let isCheckeded = self.saveData.object(forKey: ex + "@check") as! Bool
        
        self.saveData.set(savedMemoText, forKey: post + "@memo")
        self.saveData.removeObject(forKey: ex + "@memo")
        
        self.saveData.set(isShownParts, forKey: post + "@ison")
        self.saveData.removeObject(forKey: ex + "@ison")
        
        if savedDate != nil {
            self.saveData.set(savedDate!, forKey: post + "@date")
            self.saveData.removeObject(forKey: ex + "@date")
        }
        
        self.saveData.set(isCheckeded, forKey: post + "@check")
        self.saveData.removeObject(forKey: ex + "@check")
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
