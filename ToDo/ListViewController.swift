//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var navBar: UINavigationBar!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var listNameArray = [String]()
    var searchArray = [String]()
    
    var filesDict = [String: [String]]()
    
    var saveData = UserDefaults.standard
    
    var numberOfCellsInScreen = 0
    
    var statusNavHeight: CGFloat = 0.0
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        
        listNameArray = saveData.object(forKey: "@folders") as! [String]
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        searchBar.delegate = self
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.autocapitalizationType = .none
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        let partial = NSLocalizedString("部分", comment: "")
        let exact = NSLocalizedString("完全", comment: "")
        
        searchBar.scopeButtonTitles = [partial, exact]
        
        numberOfCellsInScreen = Int(ceil((view.frame.height - (UIApplication.shared.statusBarFrame.height + navBar.frame.height + searchBar.frame.height)) / table.rowHeight))
        
        navBar.topItem?.title = NSLocalizedString("フォルダ", comment: "")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text!.isEmpty {
            return listNameArray.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        if searchBar.text!.isEmpty {
            cell?.textLabel?.text = listNameArray[indexPath.row]
        } else {
            cell?.textLabel?.text = searchArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines = 0
        
        if cell?.textLabel?.text == saveData.object(forKey: "@folderName") as! String? {
            cell?.selectionStyle = .none
            cell?.textLabel?.textColor = .lightGray
        } else {
            cell?.selectionStyle = .default
            cell?.textLabel?.textColor = .black
        }
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let folderName = saveData.object(forKey: "@folderName") as! String
        
        if searchBar.text!.isEmpty {
            if listNameArray[indexPath.row] != folderName {
                return indexPath
            } else {
                return nil
            }
        } else {
            if searchArray[indexPath.row] != folderName {
                return indexPath
            } else {
                return nil
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fromFolderName = saveData.object(forKey: "@folderName") as! String
        let fileName = self.appDelegate.movingFileName
        
        let formerKey = fromFolderName + "@" + fileName
        
        if searchBar.text!.isEmpty {
            let fileIndex = filesDict[listNameArray[indexPath.row]]!.index(of: fileName)
            
            let latterKey = self.listNameArray[indexPath.row] + "@" + fileName
            
            if fileIndex == nil {
                self.filesDict[self.listNameArray[indexPath.row]]!.append(fileName)
                
                let index = self.filesDict[fromFolderName]!.index(of: fileName)!
                self.filesDict[fromFolderName]?.remove(at: index)
                
                resaveDate(pre: formerKey, post: latterKey)
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                
                appDelegate.isFromListView = true
                
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("置き換え", comment: ""),
                    message: NSLocalizedString("同名のファイルがあります", comment: ""),
                    preferredStyle: .alert)
                
                let moveAction = UIAlertAction(title: NSLocalizedString("置換", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                    self.filesDict[self.listNameArray[indexPath.row]]!.remove(at: fileIndex!)
                    self.filesDict[self.listNameArray[indexPath.row]]!.append(fileName)
                    
                    let index = self.filesDict[fromFolderName]!.index(of: fileName)!
                    self.filesDict[fromFolderName]?.remove(at: index)
                    
                    self.resaveDate(pre: formerKey, post: latterKey)
                    
                    self.saveData.set(self.filesDict, forKey: "@dictData")
                    
                    self.appDelegate.isFromListView = true
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                    self.deselectCell()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(moveAction)
                
                present(alert, animated: true, completion: nil)
            }
        } else {
            let fileIndex = filesDict[searchArray[indexPath.row]]!.index(of: fileName)
            
            let latterKey = searchArray[indexPath.row] + "@" + fileName
            
            if fileIndex == nil {
                filesDict[searchArray[indexPath.row]]!.append(fileName)
                
                let index = filesDict[fromFolderName]!.index(of: fileName)!
                filesDict[fromFolderName]?.remove(at: index)
                
                resaveDate(pre: formerKey, post: latterKey)
                
                saveData.set(filesDict, forKey: "@dictData")
                
                appDelegate.isFromListView = true
                
                self.dismiss(animated: true, completion: nil)
            } else {
                let alert = UIAlertController(
                    title: NSLocalizedString("置き換え", comment: ""),
                    message: NSLocalizedString("同名のファイルがあります", comment: ""),
                    preferredStyle: .alert)
                
                let moveAction = UIAlertAction(title: NSLocalizedString("置換", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                    self.filesDict[self.searchArray[indexPath.row]]!.remove(at: fileIndex!)
                    self.filesDict[self.searchArray[indexPath.row]]!.append(fileName)
                    
                    let index = self.filesDict[fromFolderName]!.index(of: fileName)!
                    self.filesDict[fromFolderName]?.remove(at: index)
                    
                    self.resaveDate(pre: formerKey, post: latterKey)
                    
                    self.saveData.set(self.filesDict, forKey: "@dictData")
                    
                    self.appDelegate.isFromListView = true
                    
                    self.dismiss(animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                    self.deselectCell()
                }
                
                alert.addAction(cancelAction)
                alert.addAction(moveAction)
                
                present(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func add() {
        let alert = UIAlertController(
            title: NSLocalizedString("フォルダ追加", comment: ""),
            message: NSLocalizedString("タイトル入力", comment: ""),
            preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
                if self.listNameArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.listNameArray.append(textField.text!)
                        
                        self.saveData.set(self.listNameArray, forKey: "@folders")
                        
                        self.table.reloadData()
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        if self.searchBar.text!.isEmpty {
                            if self.listNameArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchBar.frame.height + self.table.rowHeight * CGFloat(self.listNameArray.count) - self.view.frame.height
                                
                                let location = CGPoint(x: 0, y: movingHeight)
                                self.table.setContentOffset(location, animated: true)
                            }
                        } else {
                            if self.searchArray.count >= self.numberOfCellsInScreen {
                                self.showSearchResult()
                                
                                let movingHeight = self.searchBar.frame.height + self.table.rowHeight * CGFloat(self.listNameArray.count) - self.view.frame.height
                                
                                let location = CGPoint(x: 0, y: movingHeight)
                                self.table.setContentOffset(location, animated: true)
                            }
                        }
                    } else {
                        self.showalert(message: NSLocalizedString("\'@\'は使用できません", comment: ""))
                        
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
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ListViewController.closeKeyboard))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        
        self.view.gestureRecognizers?.removeAll()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.isEmpty {
            searchArray.removeAll()
            searchArray = listNameArray
            
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
    
    func deselectCell() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            searchArray = listNameArray.filter {
                $0.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current))
            }
        case 1:
            searchArray = listNameArray.filter {
                $0.lowercased(with: .current) == searchBar.text!.lowercased(with: .current)
            }
        default:
            break
        }
        
        table.reloadData()
    }
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let isShownParts = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let isChecked = saveData.object(forKey: pre + "@check") as! Bool
        
        self.saveData.set(savedMemoText, forKey: post + "@memo")
        self.saveData.removeObject(forKey: pre + "@memo")
        
        self.saveData.set(isShownParts, forKey: post + "@ison")
        self.saveData.removeObject(forKey: pre + "@ison")
        
        if savedDate != nil {
            self.saveData.set(savedDate, forKey: post + "@date")
            self.saveData.removeObject(forKey: pre + "@date")
        }
        
        self.saveData.set(isChecked, forKey: post + "@check")
        self.saveData.removeObject(forKey: pre + "@check")
    }
    
    // MARK: - Else
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
