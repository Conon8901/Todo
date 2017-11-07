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
    
    var deleteAllButton: UIBarButtonItem?
    
    var saveData = UserDefaults.standard
    
    var filesDict = [String: [String]]()
    var searchArray = [String]()
    
    var openedFolder = ""
    
    var statusNavHeight: CGFloat = 0.0
    
    var numberOfCellsInScreen = 0
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        searchBar.delegate = self
        
        table.setUp()
        searchBar.setUp()
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        openedFolder = saveData.object(forKey: "@folderName") as! String
        
        searchArray = filesDict[openedFolder]!
        
        editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        
        deleteAllButton?.title = NSLocalizedString("ALERT_TITLE_DELETEALL", comment: "")
        deleteAllButton?.isEnabled = true
        deleteAllButton?.tintColor = UIColor(white: 1, alpha: 1)
        
        deleteAllButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(FileViewController.deleteAll))
        
        self.navigationItem.leftBarButtonItem = nil
        
        statusNavHeight = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height
        
        numberOfCellsInScreen = Int(ceil((view.frame.height - (statusNavHeight + searchBar.frame.height)) / table.rowHeight))
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.putCheckmark))
        table.addGestureRecognizer(longPressRecognizer)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: openedFolder, style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = openedFolder
        
        if variables.shared.isFromListView {
            filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
            
            variables.shared.isFromListView = false
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
        } else {
            fileName = searchArray[indexPath.row]
        }
        
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
                    if self.filesDict[self.openedFolder]?.index(of: textField.text!) == nil {
                        if !textField.text!.contains("@") {
                            if self.searchBar.text!.isEmpty {
                                let preKey = self.openedFolder + "@" + self.filesDict[self.openedFolder]![indexPath.row]
                                let postKey = self.openedFolder + "@" + textField.text!
                                
                                self.resaveDate(pre: preKey, post: postKey)
                                
                                self.filesDict[self.openedFolder]?[indexPath.row] = textField.text!
                            } else {
                                let fileName = self.searchArray[indexPath.row]
                                
                                let preKey = self.openedFolder + "@" + self.searchArray[indexPath.row]
                                let postKey = self.openedFolder + "@" + textField.text!
                                
                                self.resaveDate(pre: preKey, post: postKey)
                                
                                self.searchArray[indexPath.row] = textField.text!
                                
                                let index = self.filesDict[self.openedFolder]?.index(of: fileName)
                                self.filesDict[self.openedFolder]?[index!] = textField.text!
                                
                                self.assignSearchResult()
                                
                                self.checkIsArrayEmpty()
                            }
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            
                            self.table.reloadData()
                        } else {
                            self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if textField.text != self.filesDict[self.openedFolder]?[indexPath.row] {
                            self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FILE", comment: ""))
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
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("CELL_DELETE", comment: "")) { (action, index) -> Void in
            if self.searchBar.text!.isEmpty {
                let key = self.openedFolder + "@" + self.filesDict[self.openedFolder]![indexPath.row]
                self.removeAllObject(key: key)
                
                self.filesDict[self.openedFolder]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            } else {
                let key = self.openedFolder + "@" + self.searchArray[indexPath.row]
                self.removeAllObject(key: key)
                
                self.filesDict[self.openedFolder]!.remove(at: self.filesDict[self.openedFolder]!.index(of: self.searchArray[indexPath.row])!)
                self.searchArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            }
            
            if self.filesDict[self.openedFolder]!.count < self.numberOfCellsInScreen {
                self.table.scroll(y: -self.statusNavHeight)
            }
            
            self.saveData.set(self.filesDict, forKey: "@dictData")
            
            self.checkIsArrayEmpty()
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("CELL_MOVE", comment: "")) { (action, index) -> Void in
            if self.searchBar.text!.isEmpty {
                variables.shared.movingFileName = self.filesDict[self.openedFolder]![indexPath.row]
            } else {
                variables.shared.movingFileName = self.searchArray[indexPath.row]
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
            title: NSLocalizedString("ALERT_TITLE_ADD", comment: ""),
            message: NSLocalizedString("ALERT_MESSAGE_ENTER", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_ADD", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
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
                            if self.filesDict[self.openedFolder]!.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchBar.frame.height + self.table.rowHeight * CGFloat(self.filesDict[self.openedFolder]!.count) - self.view.frame.height
                                
                                self.table.scroll(y: movingHeight)
                            }
                        } else {
                            self.assignSearchResult()
                            
                            if self.searchArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchBar.frame.height + self.table.rowHeight * CGFloat(self.searchArray.count) - self.view.frame.height
                                
                                self.table.scroll(y: movingHeight)
                            }
                        }
                        
                        self.checkIsArrayEmpty()
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        self.table.reloadData()
                    } else {
                        self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FILE", comment: ""))
                    
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
    
    @objc func putCheckmark(recognizer: UILongPressGestureRecognizer) {
        let indexPath = table.indexPathForRow(at: recognizer.location(in: table))
        
        if indexPath != nil {
            if recognizer.state == .began {
                if let cell = table.cellForRow(at: indexPath!) {
                    if cell.accessoryType == .none {
                        cell.accessoryType = .checkmark
                        
                        if searchBar.text!.isEmpty {
                            saveData.set(true, forKey: openedFolder + "@" + filesDict[openedFolder]![indexPath!.row] + "@check")
                        } else {
                            saveData.set(true, forKey: openedFolder + "@" + searchArray[indexPath!.row] + "@check")
                        }
                    } else {
                        cell.accessoryType = .none
                        
                        if searchBar.text!.isEmpty {
                            saveData.set(false, forKey: openedFolder + "@" + filesDict[openedFolder]![indexPath!.row] + "@check")
                        } else {
                            saveData.set(false, forKey: openedFolder + "@" + searchArray[indexPath!.row] + "@check")
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func tapEdit() {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            
            editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
            
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
            
            editButton.title = NSLocalizedString("NAV_BUTTON_DONE", comment: "")
            
            navigationItem.hidesBackButton = true
            
            self.navigationItem.leftBarButtonItem = deleteAllButton
            
            table.gestureRecognizers?.removeAll()
        }
    }
    
    @objc func deleteAll() {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_DELETEALL", comment: ""),
            message: NSLocalizedString("ALERT_MESSAGE_DELETEALL", comment: ""),
            preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DELETE", comment: ""), style: .destructive) { (action: UIAlertAction!) -> Void in
            let files = self.filesDict[self.openedFolder]!
            
            if !files.isEmpty {
                for fileName in files {
                    self.removeAllObject(key: self.openedFolder + "@" + fileName)
                }
                
                self.filesDict[self.openedFolder] = []
                self.searchArray = []
                
                self.editButton.isEnabled = true
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                
                self.table.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
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
        } else {
            assignSearchResult()
        }
        
        checkIsArrayEmpty()
        
        table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if !searchBar.text!.isEmpty {
            assignSearchResult()
            
            checkIsArrayEmpty()
            
            table.reloadData()
            
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        
        checkIsArrayEmpty()
        
        table.reloadData()
    }
    
    @objc func closeKeyboard() {
        searchBar.endEditing(true)
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_ERROR", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkIsArrayEmpty() {
        if searchBar.text!.isEmpty {
            if filesDict[openedFolder]!.isEmpty {
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
        
        switch searchBar.selectedScopeButtonIndex {
        case 0:
            searchArray = filesDict[openedFolder]!.filter {
                $0.lowercased(with: .current).contains(searchBar.text!.lowercased(with: .current))
            }
        case 1:
            searchArray = filesDict[openedFolder]!.filter {
                $0.lowercased(with: .current) == searchBar.text!.lowercased(with: .current)
            }
        default:
            break
        }
    }
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let savedisShownParts = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let savedisCheckeded = saveData.object(forKey: pre + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: post + "@memo")
        
        saveData.set(savedisShownParts, forKey: post + "@ison")
        
        if savedDate != nil {
            saveData.set(savedDate!, forKey: post + "@date")
        }
        
        saveData.set(savedisCheckeded, forKey: post + "@check")
        
        removeAllObject(key: pre)
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
