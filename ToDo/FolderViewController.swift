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
    
    var filesDict = [String: [String]]()
    
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
        
        if saveData.object(forKey: "@dictData") == nil {
            saveData.set(filesDict, forKey: "@dictData")
        } else {
            filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
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
                                let formertitle = self.folderNameArray[indexPath.row]
                                
                                let folderName = self.folderNameArray[indexPath.row]
                                
                                if let files = self.filesDict[folderName] {
                                    for fileName in files {
                                        let formerkey = folderName + "@" + fileName
                                        let latterkey = textField.text! + "@" + fileName
                                        
                                        self.resaveMemo(ex: formerkey, post: latterkey)
                                    }
                                }
                                
                                self.filesDict[textField.text!] = self.filesDict[folderName]
                                self.filesDict[formertitle] = nil
                                
                                self.saveData.set(self.filesDict, forKey: "@dictData")
                                
                                self.folderNameArray[indexPath.row] = textField.text!
                            } else {
                                let formertitle = self.searchArray[indexPath.row]
                                
                                let folderName = self.searchArray[indexPath.row]
                                
                                if let files = self.filesDict[folderName] {
                                    for fileName in files {
                                        let formerkey = folderName + "@" + fileName
                                        let latterkey = textField.text! + "@" + fileName
                                        
                                        self.resaveMemo(ex: formerkey, post: latterkey)
                                    }
                                    
                                    self.showSearchResult()
                                }
                                
                                self.filesDict[textField.text!] = self.filesDict[folderName]
                                self.filesDict[formertitle] = nil
                                
                                self.saveData.set(self.filesDict, forKey: "@dictData")
                                
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
                for fileName in filesDict[folderNameArray[indexPath.row]]! {
                    removeAllObject(key: folderNameArray[indexPath.row] + "@" + fileName)
                }
                
                filesDict[folderNameArray[indexPath.row]] = nil
                
                self.saveData.set(filesDict, forKey: "@dictData")
                
                folderNameArray.remove(at: indexPath.row)
            } else {
                for fileName in filesDict[searchArray[indexPath.row]]! {
                    removeAllObject(key: searchArray[indexPath.row] + "@" + fileName)
                }
                
                filesDict[searchArray[indexPath.row]] = nil
                
                self.saveData.set(filesDict, forKey: "@dictData")
                
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
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.folderNameArray, forKey: "@folders")
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
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
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            searchArray = folderNameArray.filter {
                $0.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current))
            }
        case 1:
            searchArray = folderNameArray.filter {
                $0.lowercased(with: .current) == searchBar.text!.lowercased(with: .current)
            }
        case 2:
            searchArray = folderNameArray.filter {
                $0.lowercased(with: .current).hasPrefix(searchBar.text!.lowercased(with: .current))
            }
        case 3:
            searchArray = folderNameArray.filter {
                $0.lowercased(with: .current).hasSuffix(searchBar.text!.lowercased(with: .current))
            }
        default:
            break
        }
        
        table.reloadData()
    }
    
    func resaveMemo(ex: String, post: String) {
        let memoTextView = self.saveData.object(forKey: ex + "@memo") as! String
        let dateSwitch = self.saveData.object(forKey: ex + "@ison") as! Bool
        let datePicker = self.saveData.object(forKey: ex + "@date") as! Date?
        let isCheck = self.saveData.object(forKey: ex + "@check") as! Bool
        
        self.saveData.set(memoTextView, forKey: post + "@memo")
        
        self.saveData.set(dateSwitch, forKey: post + "@ison")
        
        if datePicker != nil {
            self.saveData.set(datePicker!, forKey: post + "@date")
        }
        
        self.saveData.set(isCheck, forKey: post + "@check")
        
        removeAllObject(key: ex)
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
