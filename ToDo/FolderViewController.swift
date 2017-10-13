//
//  ViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    var saveData = UserDefaults.standard
    
    var folderNameArray = [String]()
    var searchArray = [String]()
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
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
        
        navigationItem.title = NSLocalizedString("フォルダ", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if saveData.object(forKey: "@folders") == nil {
            self.saveData.set(self.folderNameArray, forKey: "@folders")
        } else {
            folderNameArray = saveData.object(forKey: "@folders") as! [String]
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
            return folderNameArray.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if searchBar.text!.isEmpty {
            cell?.textLabel?.text = folderNameArray[indexPath.row]
        } else {
            cell?.textLabel?.text = searchArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            var beforetitle = ""
            
            let alert = UIAlertController(
                title: NSLocalizedString("名称変更", comment: ""),
                message: NSLocalizedString("タイトル入力", comment: ""),
                preferredStyle: .alert)
            
            let changeAction = UIAlertAction(title: NSLocalizedString("変更", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as UITextField
                
                let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
                
                if isBlank {
                    self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                    
                    self.deselectCell()
                } else {
                    if self.folderNameArray.index(of: textField.text!) != nil {
                        if textField.text != self.folderNameArray[indexPath.row] {
                            self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                        }
                        
                        self.deselectCell()
                    } else {
                        if textField.text!.contains("@") {
                            self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                            
                            self.deselectCell()
                        } else {
                            if self.searchBar.text!.isEmpty {
                                beforetitle = self.folderNameArray[indexPath.row]
                                
                                if self.saveData.object(forKey: "@dictData") != nil {
                                    var dict = self.saveData.object(forKey: "@dictData") as! [String: Array<String>]
                                    
                                    let folderName = self.folderNameArray[indexPath.row]
                                    
                                    if let files = dict[folderName] {
                                        for fileName in files {
                                            let formerkey = folderName + "@" + fileName
                                            let laterkey = textField.text! + "@" + fileName
                                            
                                            self.resaveMemo(formerkey, laterkey)
                                        }
                                    }
                                    
                                    dict[textField.text!] = dict[folderName]
                                    dict[beforetitle] = nil
                                    
                                    self.saveData.set(dict, forKey: "@dictData")
                                }
                                
                                self.folderNameArray[indexPath.row] = textField.text!
                            } else {
                                beforetitle = self.searchArray[indexPath.row]
                                
                                if self.saveData.object(forKey: "@dictData") != nil {
                                    var dict = self.saveData.object(forKey: "@dictData") as! [String: Array<String>]
                                    
                                    let folderName = self.searchArray[indexPath.row]
                                    
                                    if let files = dict[folderName] {
                                        for fileName in files {
                                            let formerkey = folderName + "@" + fileName
                                            let laterkey = textField.text! + "@" + fileName
                                            
                                            self.resaveMemo(formerkey, laterkey)
                                        }
                                        
                                        self.showSearchResult()
                                    }
                                    
                                    dict[textField.text!] = dict[folderName]
                                    dict[beforetitle] = nil
                                    
                                    self.saveData.set(dict, forKey: "@dictData")
                                }
                                
                                self.searchArray[indexPath.row] = textField.text!
                                
                                let index = self.folderNameArray.index(of: self.searchArray[indexPath.row])!
                                self.folderNameArray[index] = textField.text!
                            }
                            
                            self.saveData.set(self.folderNameArray, forKey: "@folders")
                            
                            self.table.reloadData()
                        }
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.deselectCell()
            }
            
            alert.addTextField { (textField: UITextField!) -> Void in
                if self.searchBar.text!.isEmpty {
                    textField.text = self.folderNameArray[indexPath.row]
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
                saveData.set(folderNameArray[indexPath.row], forKey: "@folderName")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@folderName")
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "File") as! FileViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if searchBar.text!.isEmpty {
                if saveData.object(forKey: "@dictData") != nil {
                    var deleteDict = saveData.object(forKey: "@dictData") as! [String: Array<String>]
                    
                    if deleteDict[folderNameArray[indexPath.row]] != nil {
                        for fileName in deleteDict[folderNameArray[indexPath.row]]! {
                            removeAllObject(key: folderNameArray[indexPath.row] + "@" + fileName)
                        }
                    }
                    
                    deleteDict[folderNameArray[indexPath.row]] = nil
                    
                    self.saveData.set(deleteDict, forKey: "@dictData")
                }
                
                folderNameArray.remove(at: indexPath.row)
            } else {
                if saveData.object(forKey: "@dictData") != nil {
                    var deleteDict = saveData.object(forKey: "@dictData") as! [String: Array<String>]
                    
                    if deleteDict[searchArray[indexPath.row]] != nil {
                        for fileName in deleteDict[searchArray[indexPath.row]]! {
                            removeAllObject(key: searchArray[indexPath.row] + "@" + fileName)
                        }
                    }
                    
                    deleteDict[searchArray[indexPath.row]] = nil
                    
                    self.saveData.set(deleteDict, forKey: "@dictData")
                }
                
                folderNameArray.remove(at: folderNameArray.index(of: searchArray[indexPath.row])!)
                searchArray.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            saveData.set(self.folderNameArray, forKey: "@folders")
            
            checkIsArrayEmpty()
            
            if folderNameArray.isEmpty {
                let location = CGPoint(x: 0, y: -64)
                self.table.setContentOffset(location, animated: true)
            } else {
                if self.folderNameArray.count < 11 {
                    let location = CGPoint(x: 0, y: -64)
                    self.table.setContentOffset(location, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFolder = folderNameArray[sourceIndexPath.row]
        
        folderNameArray.remove(at: sourceIndexPath.row)
        folderNameArray.insert(movingFolder, at: destinationIndexPath.row)
        
        saveData.set(folderNameArray, forKey: "@folders")
    }
    
    @IBAction func add() {
        let alert = UIAlertController(
            title: NSLocalizedString("フォルダ追加", comment: ""),
            message: NSLocalizedString("タイトル入力", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if isBlank {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                
                self.deselectCell()
            } else {
                if self.folderNameArray.index(of: textField.text!) != nil {
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                    
                    self.deselectCell()
                } else {
                    if textField.text!.contains("@") {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselectCell()
                    } else {
                        self.folderNameArray.append(textField.text!)
                        
                        self.saveData.set(self.folderNameArray, forKey: "@folders")
                        
                        self.checkIsArrayEmpty()
                        
                        self.table.reloadData()
                        
                        if self.searchBar.text!.isEmpty {
                            if self.folderNameArray.count >= 10 {
                                let location = CGPoint(x: 0, y: self.table.contentSize.height - self.table.frame.height)
                                self.table.setContentOffset(location, animated: true)
                            }
                        } else {
                            if self.searchArray.count >= 10 {
                                let location = CGPoint(x: 0, y: self.table.contentSize.height - self.table.frame.height)
                                self.table.setContentOffset(location, animated: true)
                            }
                            
                            self.showSearchResult()
                        }
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
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            editButton.title = NSLocalizedString("完了", comment: "")
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
        if searchBar.text!.isEmpty {
            searchArray.removeAll()
            searchArray = folderNameArray
            
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
    
    func checkIsArrayEmpty() {
        if folderNameArray.isEmpty {
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
        saveData.removeObject(forKey: key)
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            searchArray = folderNameArray.filter{ $0.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current)) }
        case 1:
            searchArray = folderNameArray.filter{ $0.lowercased(with: .current) == searchBar.text!.lowercased(with: .current) }
        case 2:
            searchArray = folderNameArray.filter{ $0.lowercased(with: .current).hasPrefix(searchBar.text!.lowercased(with: .current)) }
        case 3:
            searchArray = folderNameArray.filter{ $0.lowercased(with: .current).hasSuffix(searchBar.text!.lowercased(with: .current)) }
        default:
            break
        }
        
        table.reloadData()
    }
    
    func resaveMemo(_ formerkey: String, _ laterkey: String) {
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
