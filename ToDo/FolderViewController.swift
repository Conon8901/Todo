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
    
    var numberOfCellsInScreen = 0
    
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
        
        numberOfCellsInScreen = Int(ceil((view.frame.height-(UIApplication.shared.statusBarFrame.height+navigationController!.navigationBar.frame.height+searchBar.frame.height))/table.rowHeight))
        
        editButton.title = NSLocalizedString("編集", comment: "")
        
        navigationItem.title = NSLocalizedString("フォルダ", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if saveData.object(forKey: "@folders") != nil {
            folderNameArray = saveData.object(forKey: "@folders") as! [String]
        } else {
            self.saveData.set(self.folderNameArray, forKey: "@folders")
        }
        
        if saveData.object(forKey: "@dictData") != nil {
            filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        } else {
            saveData.set(filesDict, forKey: "@dictData")
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
                
                if !isBlank {
                    if self.folderNameArray.index(of: textField.text!) == nil {
                        if !textField.text!.contains("@") {
                            var formerTitle = ""
                            var folderName = ""
                            
                            if self.searchBar.text!.isEmpty {
                                formerTitle = self.folderNameArray[indexPath.row]
                                
                                folderName = self.folderNameArray[indexPath.row]
                                
                                self.folderNameArray[indexPath.row] = textField.text!
                            } else {
                                formerTitle = self.searchArray[indexPath.row]
                                
                                folderName = self.searchArray[indexPath.row]
                                
                                self.searchArray[indexPath.row] = textField.text!
                                
                                let index = self.folderNameArray.index(of: self.searchArray[indexPath.row])!
                                self.folderNameArray[index] = textField.text!
                            }
                            
                            if let files = self.filesDict[folderName] {
                                for fileName in files {
                                    let formerKey = folderName + "@" + fileName
                                    let latterKey = textField.text! + "@" + fileName
                                    
                                    self.resaveDate(pre: formerKey, post: latterKey)
                                }
                                
                                if !self.searchBar.text!.isEmpty {
                                    self.showSearchResult()
                                }
                            }
                            
                            self.filesDict[textField.text!] = self.filesDict[folderName]
                            self.filesDict[formerTitle] = nil
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            
                            self.saveData.set(self.folderNameArray, forKey: "@folders")
                            
                            self.table.reloadData()
                        } else {
                            self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                            
                            self.deselectCell()
                        }
                    } else {
                        if textField.text != self.folderNameArray[indexPath.row] {
                            self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
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
                
                folderNameArray.remove(at: indexPath.row)
            } else {
                for fileName in filesDict[searchArray[indexPath.row]]! {
                    removeAllObject(key: searchArray[indexPath.row] + "@" + fileName)
                }
                
                filesDict[searchArray[indexPath.row]] = nil
                
                folderNameArray.remove(at: folderNameArray.index(of: searchArray[indexPath.row])!)
                searchArray.remove(at: indexPath.row)
            }
            
            self.saveData.set(filesDict, forKey: "@dictData")
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            saveData.set(self.folderNameArray, forKey: "@folders")
            
            checkIsArrayEmpty()
            
            if self.folderNameArray.count < self.numberOfCellsInScreen {
                let location = CGPoint(x: 0, y: -UIApplication.shared.statusBarFrame.height+self.navigationController!.navigationBar.frame.height)
                self.table.setContentOffset(location, animated: true)
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
            
            if !isBlank {
                if self.folderNameArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.folderNameArray.append(textField.text!)
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.folderNameArray, forKey: "@folders")
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        self.checkIsArrayEmpty()
                        
                        self.table.reloadData()
                        
                        if self.searchBar.text!.isEmpty {
                            if self.folderNameArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchBar.frame.height+self.table.rowHeight*CGFloat(self.folderNameArray.count)-self.view.frame.height
                                
                                let location = CGPoint(x: 0, y: movingHeight)
                                self.table.setContentOffset(location, animated: true)
                            }
                        } else {
                            self.showSearchResult()
                            
                            if self.searchArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchBar.frame.height+self.table.rowHeight*CGFloat(self.searchArray.count)-self.view.frame.height
                                
                                let location = CGPoint(x: 0, y: movingHeight)
                                self.table.setContentOffset(location, animated: true)
                            }
                        }
                    } else {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(FolderViewController.closeKeyboard))
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
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = self.saveData.object(forKey: pre + "@memo") as! String
        let isShownParts = self.saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = self.saveData.object(forKey: pre + "@date") as! Date?
        let isChecked = self.saveData.object(forKey: pre + "@check") as! Bool
        
        self.saveData.set(savedMemoText, forKey: post + "@memo")
        
        self.saveData.set(isShownParts, forKey: post + "@ison")
        
        if savedDate != nil {
            self.saveData.set(savedDate!, forKey: post + "@date")
        }
        
        self.saveData.set(isChecked, forKey: post + "@check")
        
        removeAllObject(key: pre)
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
