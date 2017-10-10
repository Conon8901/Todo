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
    @IBOutlet var navTitleButton: UIButton!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var saveData = UserDefaults.standard
    
    var showDict = [String: Array<String>]()
    var searchArray = [String]()
    
    var openedFolder = ""
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        if saveData.object(forKey: "@dictData") == nil {
            self.saveData.set(self.showDict, forKey: "@dictData")
        } else {
            showDict = saveData.object(forKey: "@dictData") as! [String: Array<String>]
        }
        
        openedFolder = saveData.object(forKey: "@folderName") as! String
        
        if showDict[openedFolder] == nil {
            showDict[openedFolder] = []
        }
        
        searchArray = showDict[openedFolder]!
        
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        let partial = NSLocalizedString("部分", comment: "")
        let exact = NSLocalizedString("完全", comment: "")
        let forward = NSLocalizedString("前方", comment: "")
        let backward = NSLocalizedString("後方", comment: "")
        
        searchBar.scopeButtonTitles = [partial, exact, forward, backward]
        
        editButton.title = NSLocalizedString("編集", comment: "")
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: openedFolder, style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navTitleButton.setTitle(openedFolder, for: .normal)
        
        if appDelegate.isFromListView {
            showDict = saveData.object(forKey: "@dictData") as! [String: Array<String>]
            
            appDelegate.isFromListView = false
        }
        
        if showDict[openedFolder]!.isEmpty {
            navTitleButton.isEnabled = false
            
            self.navTitleButton.gestureRecognizers?.removeAll()
        } else {
            navTitleButton.isEnabled = true
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.allRemove(_:)))
            self.navTitleButton.addGestureRecognizer(longPressGesture)
        }
        
        checkIsArrayIsEmpty()
        
        table.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text == "" {
            return showDict[openedFolder]!.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        if searchBar.text == "" {
            cell?.textLabel?.text = showDict[openedFolder]?[indexPath.row]
            
            let fileName = showDict[openedFolder]?[indexPath.row]
            if let subtitle = saveData.object(forKey: openedFolder + "@" + fileName!) as! String? {
                cell?.detailTextLabel?.text = subtitle
            }
        } else {
            cell?.textLabel?.text = searchArray[indexPath.row]
            
            let fileName = searchArray[indexPath.row]
            if let subtitle = saveData.object(forKey: openedFolder + "@" + fileName) as! String? {
                cell?.detailTextLabel?.text = subtitle
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
                
                if isBlank {
                    self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                    
                    self.deselect()
                } else {
                    var isSameName = false
                    
                    for i in 1...self.showDict[self.openedFolder]!.count {
                        if self.showDict[self.openedFolder]?[i-1] == textField.text! {
                            isSameName = true
                        }
                    }
                    
                    if isSameName {
                        if textField.text != self.showDict[self.openedFolder]?[indexPath.row] {
                            self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                        }
                        
                        self.deselect()
                    } else {
                        if textField.text!.contains("@") {
                            self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                            
                            self.deselect()
                        } else {
                            if self.searchBar.text == "" {
                                let formerkey = self.openedFolder + "@" + self.showDict[self.openedFolder]![indexPath.row]
                                let laterkey = self.openedFolder + "@" + textField.text!
                                
                                self.resave(formerkey, laterkey)
                                
                                self.showDict[self.openedFolder]?[indexPath.row] = textField.text!
                            } else {
                                let fileName = self.searchArray[indexPath.row]
                                
                                let formerkey = self.openedFolder + "@" + self.searchArray[indexPath.row]
                                let laterkey = self.openedFolder + "@" + textField.text!
                                
                                self.resave(formerkey, laterkey)
                                
                                self.searchArray[indexPath.row] = textField.text!
                                
                                let index = self.showDict[self.openedFolder]?.index(of: fileName)
                                self.showDict[self.openedFolder]?[index!] = textField.text!
                                
                                self.showSearchResult()
                            }
                            
                            self.saveData.set(self.showDict, forKey: "@dictData")
                            
                            self.table.reloadData()
                        }
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.deselect()
            }
            
            alert.addTextField { (textField: UITextField!) -> Void in
                if self.searchBar.text == "" {
                    textField.text = self.showDict[self.openedFolder]?[indexPath.row]
                } else {
                    textField.text = self.searchArray[indexPath.row]
                }
                
                textField.textAlignment = .left
            }
            
            alert.addAction(cancelAction)
            alert.addAction(changeAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            if searchBar.text == "" {
                saveData.set(showDict[openedFolder]![indexPath.row], forKey: "@fileName")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@fileName")
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Memo") as! MemoViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("削除", comment: "")) { (action, index) -> Void in
            if self.searchBar.text == "" {
                let key = self.openedFolder + "@" + self.showDict[self.openedFolder]![indexPath.row]
                self.removeAllObject(key: key)
                
                self.showDict[self.openedFolder]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                
                if self.showDict[self.openedFolder]!.isEmpty {
                    self.navTitleButton.isEnabled = false
                    self.navTitleButton.gestureRecognizers?.removeAll()
                }
            } else {
                let key = self.openedFolder + "@" + self.searchArray[indexPath.row]
                self.removeAllObject(key: key)
                
                self.showDict[self.openedFolder]?.remove(at: self.showDict[self.openedFolder]!.index(of: self.searchArray[indexPath.row])!)
                self.searchArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                
                if self.searchArray.isEmpty {
                    self.navTitleButton.isEnabled = false
                    self.navTitleButton.gestureRecognizers?.removeAll()
                }
            }
            
            if self.showDict[self.openedFolder]!.count < 11 {
                let location = CGPoint(x: 0, y: -64)
                self.table.setContentOffset(location, animated: true)
            }
            
            self.saveData.set(self.showDict, forKey: "@dictData")
            
            self.checkIsArrayIsEmpty()
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("移動", comment: "")) { (action, index) -> Void in
            if self.searchBar.text == "" {
                self.appDelegate.movingFileName = self.showDict[self.openedFolder]![indexPath.row]
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
        let movingFile = showDict[openedFolder]?[sourceIndexPath.row]
        
        showDict[openedFolder]?.remove(at: sourceIndexPath.row)
        showDict[openedFolder]?.insert(movingFile!, at: destinationIndexPath.row)
        
        saveData.set(showDict, forKey: "@dictData")
        
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
            
            if isBlank {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            } else {
                var isSameName = false
                
                if self.showDict[self.openedFolder]?.isEmpty == false {
                    for i in 1...self.showDict[self.openedFolder]!.count {
                        if self.showDict[self.openedFolder]?[i-1] == textField.text! {
                            isSameName = true
                        }
                    }
                }
                
                if isSameName {
                    self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                    
                    self.deselect()
                } else {
                    if textField.text!.contains("@") {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    } else {
                        self.showDict[self.openedFolder]!.append(textField.text!)
                        
                        self.navTitleButton.isEnabled = true
                        
                        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.allRemove(_:)))
                        self.navTitleButton.addGestureRecognizer(longPressGesture)
                        
                        if self.searchBar.text == "" {
                            if self.showDict[self.openedFolder]!.count >= 11 {
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
                        
                        self.saveData.set(self.showDict, forKey: "@dictData")
                        
                        self.checkIsArrayIsEmpty()
                        
                        self.table.reloadData()
                    }
                }
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
    
    @IBAction func tapEdit() {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            
            editButton.title = NSLocalizedString("編集", comment: "")
            
            navigationItem.hidesBackButton = false
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            editButton.title = NSLocalizedString("完了", comment: "")
            
            navigationItem.hidesBackButton = true
        }
    }
    
    func allRemove(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let alert = UIAlertController(
                title: NSLocalizedString("全削除", comment: ""),
                message: NSLocalizedString("本当によろしいですか？\nこのフォルダの全ファイルを削除します", comment: ""),
                preferredStyle: .alert)
            
            let deleteAction = UIAlertAction(title: NSLocalizedString("削除", comment: ""), style: .destructive) { (action: UIAlertAction!) -> Void in
                let filescount = self.showDict[self.openedFolder]!.count
                
                if filescount != 0 {
                    for i in 1...filescount {
                        let key = self.openedFolder + "@" + self.showDict[self.openedFolder]![i-1]
                        self.removeAllObject(key: key)
                    }
                    
                    self.showDict[self.openedFolder] = []
                    self.searchArray = []
                    
                    self.editButton.isEnabled = false
                    
                    self.navTitleButton.isEnabled = false
                    self.navTitleButton.gestureRecognizers?.removeAll()
                    
                    self.saveData.set(self.showDict, forKey: "@dictData")
                    
                    self.table.reloadData()
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
            }
            
            alert.addAction(cancelAction)
            alert.addAction(deleteAction)
            
            present(alert, animated: true, completion: nil)
        }
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
        if searchBar.text == "" {
            searchArray.removeAll()
            searchArray = showDict[openedFolder]!
            
            table.reloadData()
        } else {
            showSearchResult()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.text != "" {
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
    
    func closeKeyboard() {
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
    
    func checkIsArrayIsEmpty() {
        if showDict[openedFolder]!.isEmpty {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
    
    func deselect() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key)
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        
        for fileName in showDict[openedFolder]! {
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if fileName.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current)) {
                    searchArray.append(fileName)
                }
            case 1:
                if fileName.lowercased(with: .current) == searchBar.text!.lowercased(with: .current) {
                    searchArray.append(fileName)
                }
            case 2:
                if fileName.lowercased(with: .current).hasPrefix(searchBar.text!.lowercased(with: .current)) {
                    searchArray.append(fileName)
                }
            case 3:
                if fileName.lowercased(with: .current).hasSuffix(searchBar.text!.lowercased(with: .current)) {
                    searchArray.append(fileName)
                }
            default:
                break
            }
        }
        
        table.reloadData()
    }
    
    func resave(_ formerkey: String, _ laterkey: String) {
        let memoTextView = self.saveData.object(forKey: formerkey) as! String?
        let dateSwitch = self.saveData.object(forKey: formerkey + "@ison") as! Bool?
        let datePicker = self.saveData.object(forKey: formerkey + "@date") as! Date?
        
        if memoTextView != nil {
            self.saveData.set(memoTextView!, forKey: laterkey)
            self.saveData.removeObject(forKey: formerkey)
        }
        
        if dateSwitch != nil {
            self.saveData.set(dateSwitch!, forKey: laterkey + "@ison")
            self.saveData.removeObject(forKey: formerkey + "@ison")
        }
        
        if datePicker != nil {
            self.saveData.set(datePicker!, forKey: laterkey + "@date")
            self.saveData.removeObject(forKey: formerkey + "@date")
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
