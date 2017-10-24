//
//  ViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FolderViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var saveData = UserDefaults.standard
    
    var folderNameArray = [String]()
    var searchArray = [String]()
    
    var filesDict = [String: [String]]()
    
    var numberOfCellsInScreen = 0
    
    var statusNavHeight: CGFloat = 0.0
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.rowHeight = 60
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        table.tableHeaderView = searchController.searchBar
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        statusNavHeight = UIApplication.shared.statusBarFrame.height + self.navigationController!.navigationBar.frame.height
        
        numberOfCellsInScreen = Int(ceil((view.frame.height - (statusNavHeight + searchController.searchBar.frame.height)) / table.rowHeight))
        
        editButton.title = NSLocalizedString("EDIT", comment: "")
        
        navigationItem.title = NSLocalizedString("FOLDER", comment: "")
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
        if searchController.searchBar.text!.isEmpty {
            return folderNameArray.count
        } else {
            return searchArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if searchController.searchBar.text!.isEmpty {
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
                title: NSLocalizedString("CHANGE-NAME", comment: ""),
                message: NSLocalizedString("ENTER-TITLE", comment: ""),
                preferredStyle: .alert)
            
            let changeAction = UIAlertAction(title: NSLocalizedString("CHANGE", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as UITextField
                
                let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
                
                if !isBlank {
                    if self.folderNameArray.index(of: textField.text!) == nil {
                        if !textField.text!.contains("@") {
                            var formerTitle = ""
                            var folderName = ""
                            
                                formerTitle = self.folderNameArray[indexPath.row]
                                
                                folderName = self.folderNameArray[indexPath.row]
                                
                                self.folderNameArray[indexPath.row] = textField.text!
                            
                            if let files = self.filesDict[folderName] {
                                for fileName in files {
                                    let formerKey = folderName + "@" + fileName
                                    let latterKey = textField.text! + "@" + fileName
                                    
                                    self.resaveDate(pre: formerKey, post: latterKey)
                                }
                            }
                            
                            self.filesDict[textField.text!] = self.filesDict[folderName]
                            self.filesDict[formerTitle] = nil
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            
                            self.saveData.set(self.folderNameArray, forKey: "@folders")
                            
                            self.table.reloadData()
                        } else {
                            self.showalert(message: NSLocalizedString("UNUSABLE-ATSIGN", comment: ""))
                            
                            self.deselectCell()
                        }
                    } else {
                        if textField.text != self.folderNameArray[indexPath.row] {
                            self.showalert(message: NSLocalizedString("SAME_FOLDER", comment: ""))
                        }
                        
                        self.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("PLEASE-ENTER", comment: ""))
                    
                    self.deselectCell()
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.deselectCell()
            }
            
            alert.addTextField { (textField: UITextField!) -> Void in
                textField.text = self.folderNameArray[indexPath.row]
                
                textField.textAlignment = .left
            }
            
            alert.addAction(cancelAction)
            alert.addAction(changeAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            if searchController.searchBar.text!.isEmpty {
                saveData.set(folderNameArray[indexPath.row], forKey: "@folderName")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@folderName")
            }
            
            self.searchController.searchBar.endEditing(true)
            searchController.isActive = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                let nextView = self.storyboard!.instantiateViewController(withIdentifier: "File") as! FileViewController
                self.navigationController?.pushViewController(nextView, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if searchController.searchBar.text!.isEmpty {
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
                let location = CGPoint(x: 0, y: -statusNavHeight)
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
            title: NSLocalizedString("ADD_TITLE", comment: ""),
            message: NSLocalizedString("ENTER-TITLE", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("ADD", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
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
                        
                            if self.folderNameArray.count >= self.numberOfCellsInScreen {
                                let movingHeight = self.searchController.searchBar.frame.height + self.table.rowHeight * CGFloat(self.folderNameArray.count) - self.view.frame.height
                                
                                let location = CGPoint(x: 0, y: movingHeight)
                                self.table.setContentOffset(location, animated: true)
                            }
                    } else {
                        self.showalert(message: NSLocalizedString("UNUSABLE-ATSIGN", comment: ""))
                        
                        self.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("SAME_FOLDER", comment: ""))
                    
                    self.deselectCell()
                }
            } else {
                self.showalert(message: NSLocalizedString("PLEASE-ENTER", comment: ""))
                
                self.deselectCell()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
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
            
            table.tableHeaderView = searchController.searchBar
            
            editButton.title = NSLocalizedString("EDIT", comment: "")
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            table.tableHeaderView = nil
            
            editButton.title = NSLocalizedString("DONE", comment: "")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        searchArray.removeAll()
        
        searchArray = folderNameArray.filter {
            $0.lowercased(with: .current).contains(searchController.searchBar.text!.lowercased(with: .current))
        }
        
        table.reloadData()
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("ERROR", comment: ""),
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
