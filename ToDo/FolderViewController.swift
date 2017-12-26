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
    
    var filesDict = [String: [String]]()
    
    var folderNameArray = [String]()
    var searchArray = [String]()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        searchBar.delegate = self
        searchBar.setUp()
        searchBar.placeholder = NSLocalizedString("SEARCH_PLACEHOLDER", comment: "")
        
        editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        
        navigationItem.title = NSLocalizedString("NAV_TITLE_FOLDER", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if saveData.object(forKey: "@folders") != nil {
            folderNameArray = saveData.object(forKey: "@folders") as! [String]
        } else {
            saveData.set(folderNameArray, forKey: "@folders")
        }
        
        if saveData.object(forKey: "@dictData") != nil {
            filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        } else {
            saveData.set(filesDict, forKey: "@dictData")
        }
        
        checkIsArrayEmpty()
        
        let indexPath = table.indexPathForSelectedRow
        
        table.reloadData()
        
        table.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) {
            self.table.deselectCell()
        }
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
                title: NSLocalizedString("ALERT_TITLE_CHANGE", comment: ""),
                message: NSLocalizedString("ALERT_MESSAGE_ENTER", comment: ""),
                preferredStyle: .alert)
            
            let changeAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CHANGE", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as UITextField
                
                let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
                
                if !isBlank {
                    if self.folderNameArray.index(of: textField.text!) == nil {
                        if !textField.text!.contains("@") {
                            var preFolderName = ""
                            
                            if self.searchBar.text!.isEmpty {
                                preFolderName = self.folderNameArray[indexPath.row]
                                
                                self.folderNameArray[indexPath.row] = textField.text!
                            } else {
                                preFolderName = self.searchArray[indexPath.row]
                                
                                self.searchArray[indexPath.row] = textField.text!
                                
                                let index = self.folderNameArray.index(of: self.searchArray[indexPath.row])!
                                self.folderNameArray[index] = textField.text!
                            }
                            
                            self.filesDict[textField.text!] = self.filesDict[preFolderName]
                            self.filesDict[preFolderName] = nil
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            self.saveData.set(self.folderNameArray, forKey: "@folders")
                            
                            if let files = self.filesDict[preFolderName] {
                                for fileName in files {
                                    let preKey = preFolderName + "@" + fileName
                                    let postKey = textField.text! + "@" + fileName
                                    
                                    self.resaveDate(pre: preKey, post: postKey)
                                }
                                
                                if !self.searchBar.text!.isEmpty {
                                    self.assignSearchResult()
                                    
                                    self.checkIsArrayEmpty()
                                }
                            }
                            
                            self.table.reloadData()
                        } else {
                            self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if textField.text != self.folderNameArray[indexPath.row] {
                            self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FOLDER", comment: ""))
                        }
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ENTER", comment: ""))
                    
                    self.table.deselectCell()
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.table.deselectCell()
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
            variables.shared.includingFiles.removeAll()
            
            if searchBar.text!.isEmpty {
                saveData.set(folderNameArray[indexPath.row], forKey: "@folderName")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@folderName")
                
                variables.shared.includingFiles = filesDict[folderNameArray[indexPath.row]]!.filter({
                    $0.partialMatch(target: searchBar.text!)
                })
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
            
            tableView.reloadData()
            
            saveData.set(filesDict, forKey: "@dictData")
            saveData.set(folderNameArray, forKey: "@folders")
            
            checkIsArrayEmpty()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = folderNameArray[sourceIndexPath.row]
        
        folderNameArray.remove(at: sourceIndexPath.row)
        folderNameArray.insert(movingItem, at: destinationIndexPath.row)
        
        saveData.set(folderNameArray, forKey: "@folders")
    }
    
    @IBAction func add() {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_ADD", comment: ""),
            message: NSLocalizedString("ALERT_MESSAGE_ENTER", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_ADD", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
                if self.folderNameArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.folderNameArray.append(textField.text!)
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        self.saveData.set(self.folderNameArray, forKey: "@folders")
                        
                        self.checkIsArrayEmpty()
                        
                        self.table.reloadData()
                        
                        self.table.scrollToRow(at: [0,self.filesDict.keys.count-1], at: .bottom, animated: true)
                    } else {
                        self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FOLDER", comment: ""))
                    
                    self.table.deselectCell()
                }
            } else {
                self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ENTER", comment: ""))
                
                self.table.deselectCell()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
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
            
            editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            editButton.title = NSLocalizedString("NAV_BUTTON_DONE", comment: "")
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
        } else {
            assignSearchResult()
            
            checkIsArrayEmpty()
        }
        
        table.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        table.reloadData()
    }
    
    @objc func closeKeyboard() {
        searchBar.endEditing(true)
    }
    
    // MARK: - Methods
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_ERROR", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CLOSE", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkIsArrayEmpty() {
        if searchBar.text!.isEmpty {
            if folderNameArray.isEmpty {
                editButton.isEnabled = false
            } else {
                editButton.isEnabled = true
            }
        } else {
            if searchArray.isEmpty {
                editButton.isEnabled = false
            } else {
                editButton.isEnabled = true
            }
        }
    }
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func assignSearchResult() {
        searchArray.removeAll()
        
        if saveData.object(forKey: "@dictData") != nil {
            let dict = saveData.object(forKey: "@dictData") as! [String: [String]]
            
            for key in dict.keys {
                var isIncluding = false
                
                for value in dict[key]! {
                    if value.partialMatch(target: searchBar.text!) {
                        isIncluding = true
                    }
                }
                
                if isIncluding {
                    searchArray.append(key)
                }
            }
        }
    }
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let savedIsShownParts = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let savedIsChecked = saveData.object(forKey: pre + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: post + "@memo")
        
        saveData.set(savedIsShownParts, forKey: post + "@ison")
        
        if savedDate != nil {
            saveData.set(savedDate!, forKey: post + "@date")
        }
        
        saveData.set(savedIsChecked, forKey: post + "@check")
        
        removeAllObject(key: pre)
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
