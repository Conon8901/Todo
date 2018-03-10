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
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchBar: UISearchBar!
    
    var saveData = UserDefaults.standard
    
    var filesDict = [String: [String]]()
    
    var folderNameArray = [String]()
    var searchArray = [String]()
    var searchDict = [String: [String]]()
    
    var cellIndex: IndexPath = [0,0]
    
    var isDataNil = false
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        searchBar.delegate = self
        searchBar.placeholder = NSLocalizedString("SEARCH_PLACEHOLDER", comment: "")
        searchBar.setUp()
        
        editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        
        navigationItem.title = NSLocalizedString("NAV_TITLE_CATEGORY", comment: "")
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
        
        if let indexPathForSelectedRow = table.indexPathForSelectedRow {
            cellIndex = indexPathForSelectedRow
        }
        
        table.reload()
        
        if variables.shared.isFromFileView {
            table.selectRow(at: cellIndex, animated: false, scrollPosition: .none)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.table.deselectRow(at: self.cellIndex, animated: true)
                
                variables.shared.isFromFileView = false
            }
        }
        
        checkIsArrayEmpty()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if folderNameArray.count == 0 {
            isDataNil = true
            
            return 1
        } else {
            isDataNil = false
            
            if searchBar.text!.isEmpty {
                return folderNameArray.count
            } else {
                return searchArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if isDataNil {
            cell?.textLabel?.text = NSLocalizedString("CELL_LABEL_ADD_CATEGORY", comment: "")
            cell?.textLabel?.textColor = .gray
            
            cell?.detailTextLabel?.text = ""
            
            table.allowsSelection = false
        } else {
            if searchBar.text!.isEmpty {
                cell?.textLabel?.text = folderNameArray[indexPath.row]
                
                cell?.detailTextLabel?.text = ""
            } else {
                cell?.textLabel?.text = searchArray[indexPath.row]
                
                var includingFiles = ""
                for files in searchDict[cell!.textLabel!.text!]! {
                    includingFiles += files + ", "
                }
                includingFiles = String(includingFiles.prefix(includingFiles.count - 2))
                
                cell?.detailTextLabel?.text = includingFiles
            }
            
            cell?.textLabel?.textColor = .black
            
            cell?.textLabel?.numberOfLines = 0
            
            table.allowsSelection = true
        }
        
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
                            
                            preFolderName = self.folderNameArray[indexPath.row]
                            
                            self.folderNameArray[indexPath.row] = textField.text!
                            
                            self.filesDict[textField.text!] = self.filesDict[preFolderName]
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            self.saveData.set(self.folderNameArray, forKey: "@folders")
                            
                            if let files = self.filesDict[preFolderName] {
                                for fileName in files {
                                    let preKey = preFolderName + "@" + fileName
                                    let postKey = textField.text! + "@" + fileName
                                    
                                    self.resaveDate(pre: preKey, post: postKey)
                                }
                            }
                            
                            self.filesDict[preFolderName] = nil
                            
                            self.table.reload()
                        } else {
                            self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if textField.text != self.folderNameArray[indexPath.row] {
                            self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME", comment: ""))
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
                textField.text = self.folderNameArray[indexPath.row]
                
                textField.textAlignment = .left
                
                textField.clearButtonMode = .whileEditing
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
                
                variables.shared.includingFiles = searchDict[searchArray[indexPath.row]]!
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "File") as! FileViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if searchBar.text!.isEmpty {
            return .delete
        } else {
            return .none
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if !isDataNil {
                let maxIndex = folderNameArray.count - 1
                
                for fileName in filesDict[folderNameArray[indexPath.row]]! {
                    removeAllObject(key: folderNameArray[indexPath.row] + "@" + fileName)
                }
                
                filesDict[folderNameArray[indexPath.row]] = nil
                
                folderNameArray.remove(at: indexPath.row)
                
                tableView.reload()
                
                if indexPath.row >= maxIndex - 1 {
                    if indexPath.row != 0 {
                        tableView.scrollToRow(at: [0,maxIndex - 1], at: .bottom, animated: true)
                    }
                } else {
                    let visibleLastCell = folderNameArray.index(of: tableView.visibleCells.last!.textLabel!.text!)! - 1
                    
                    tableView.scrollToRow(at: [0,visibleLastCell], at: .bottom, animated: true)
                }
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                self.saveData.set(self.folderNameArray, forKey: "@folders")
                
                self.checkIsArrayEmpty()
            }
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
                        
                        self.table.reload()
                        
                        self.table.scrollToRow(at: [0,self.folderNameArray.count-1], at: .bottom, animated: true)
                    } else {
                        self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME", comment: ""))
                    
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
            
            searchBar.isUserInteractionEnabled = true
            searchBar.alpha = 1
            searchBar.endEditing(true)
            
            editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            searchBar.isUserInteractionEnabled = false
            searchBar.alpha = 0.75
            
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
            addButton.isEnabled = true
            editButton.isEnabled = true
            
            searchArray.removeAll()
            searchArray = folderNameArray
        } else {
            addButton.isEnabled = false
            editButton.isEnabled = false
            
            assignSearchResult()
        }
        
        table.reload()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        addButton.isEnabled = true
        editButton.isEnabled = true
        
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        table.reload()
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
        searchDict.removeAll()
        
        if saveData.object(forKey: "@dictData") != nil {
            let dict = saveData.object(forKey: "@dictData") as! [String: [String]]
            
            for key in folderNameArray {
                var isIncluding = false
                
                for value in dict[key]! {
                    if value.partialMatch(target: searchBar.text!) {
                        isIncluding = true
                        
                        if searchDict[key] == nil {
                            searchDict[key] = [value]
                        } else {
                            searchDict[key]?.append(value)
                        }
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
