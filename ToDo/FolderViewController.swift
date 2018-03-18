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
    
    var tasksDict = [String: [String]]()
    var categoriesArray = [String]()
    var searchArray = [String]()
    var pickedDict = [String: [String]]()
    
    var isDataNil = false
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        searchBar.delegate = self
        searchBar.placeholder = "SEARCH_PLACEHOLDER".localized
        searchBar.setUp()
        
        navigationItem.title = "NAV_TITLE_CATEGORY".localized
        
        editButton.title = "NAV_BUTTON_EDIT".localized
        
        table.tableFooterView = UIView()
        
        if saveData.object(forKey: "@folders") != nil {
            categoriesArray = saveData.object(forKey: "@folders") as! [String]
        } else {
            saveData.set(categoriesArray, forKey: "@folders")
        }
        
        if saveData.object(forKey: "@dictData") != nil {
            tasksDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        } else {
            saveData.set(tasksDict, forKey: "@dictData")
        }
        
        setEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        table.deselectCell()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if categoriesArray.count == 0 {
            isDataNil = true
            
            return 1
        } else {
            isDataNil = false
            
            if searchBar.text!.isEmpty {
                return categoriesArray.count
            } else {
                return searchArray.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if isDataNil {
            cell?.textLabel?.text = "CELL_LABEL_ADD_CATEGORY".localized
            cell?.textLabel?.textColor = .gray
            
            cell?.detailTextLabel?.text = ""
            
            table.allowsSelection = false
        } else {
            if searchBar.text!.isEmpty {
                cell?.textLabel?.text = categoriesArray[indexPath.row]
                
                cell?.detailTextLabel?.text = ""
            } else {
                cell?.textLabel?.text = searchArray[indexPath.row]
                
                let includingFiles = pickedDict[cell!.textLabel!.text!]!.joined(separator: ", ")
                cell?.detailTextLabel?.text = includingFiles
            }
            
            cell?.textLabel?.textColor = .black
            
            table.allowsSelection = true
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            let alert = UIAlertController(
                title: "ALERT_TITLE_CHANGE".localized,
                message: "ALERT_MESSAGE_ENTER".localized,
                preferredStyle: .alert)
            
            let changeAction = UIAlertAction(title: "ALERT_BUTTON_CHANGE".localized, style: .default) { (action: UIAlertAction!) -> Void in
                let textField = alert.textFields![0] as UITextField
                
                let isBlank = textField.text!.existsCharacter()
                
                if isBlank {
                    if self.categoriesArray.index(of: textField.text!) == nil {
                        if !textField.text!.contains("@") {
                            let preCategoryName = self.categoriesArray[indexPath.row]
                            
                            self.categoriesArray[indexPath.row] = textField.text!
                            
                            self.tasksDict[textField.text!] = self.tasksDict[preCategoryName]
                            
                            self.saveData.set(self.tasksDict, forKey: "@dictData")
                            self.saveData.set(self.categoriesArray, forKey: "@folders")
                            
                            if let files = self.tasksDict[preCategoryName] {
                                for fileName in files {
                                    let preKey = preCategoryName + "@" + fileName
                                    let postKey = textField.text! + "@" + fileName
                                    
                                    self.resaveData(preKey, to: postKey)
                                }
                            }
                            
                            self.tasksDict.removeValue(forKey: preCategoryName)
                            
                            self.table.reload()
                        } else {
                            self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_ATSIGN".localized)
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if textField.text != self.categoriesArray[indexPath.row] {
                            self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_SAME".localized)
                        }
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_ENTER".localized)
                    
                    self.table.deselectCell()
                }
            }
            
            let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in
                self.table.deselectCell()
            }
            
            alert.addTextField { (textField: UITextField!) -> Void in
                textField.text = self.categoriesArray[indexPath.row]
                
                textField.clearButtonMode = .always
            }
            
            alert.addAction(cancelAction)
            alert.addAction(changeAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            variables.shared.includingTasks.removeAll()
            
            if searchBar.text!.isEmpty {
                saveData.set(categoriesArray[indexPath.row], forKey: "@folderName")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@folderName")
                
                variables.shared.includingTasks = pickedDict[searchArray[indexPath.row]]!
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
                let maxIndex = categoriesArray.count - 1
                let categoryName = categoriesArray[indexPath.row]
                
                tasksDict[categoryName]?.forEach({ removeAllObject(categoryName + "@" + $0 )})
                
                tasksDict.removeValue(forKey: categoryName)
                categoriesArray.remove(at: indexPath.row)
                
                tableView.reload()
                
                if indexPath.row >= maxIndex - 1 {
                    if indexPath.row != 0 {
                        tableView.scrollToRow(at: [0,maxIndex - 1], at: .bottom, animated: true)
                    }
                } else {
                    let visibleLastCell = categoriesArray.index(of: tableView.visibleCells.last!.textLabel!.text!)! - 1
                    
                    tableView.scrollToRow(at: [0,visibleLastCell], at: .bottom, animated: true)
                }
                
                self.saveData.set(self.tasksDict, forKey: "@dictData")
                self.saveData.set(self.categoriesArray, forKey: "@folders")
                
                self.setEditButton()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = categoriesArray[sourceIndexPath.row]
        
        categoriesArray.remove(at: sourceIndexPath.row)
        categoriesArray.insert(movingItem, at: destinationIndexPath.row)
        
        saveData.set(categoriesArray, forKey: "@folders")
    }
    
    @IBAction func addItem() {
        let alert = UIAlertController(
            title: "ALERT_TITLE_ADD".localized,
            message: "ALERT_MESSAGE_ENTER".localized,
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "ALERT_BUTTON_ADD".localized, style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.existsCharacter()
            
            if isBlank {
                if self.categoriesArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.categoriesArray.append(textField.text!)
                        
                        self.tasksDict[textField.text!] = []
                        
                        self.saveData.set(self.tasksDict, forKey: "@dictData")
                        self.saveData.set(self.categoriesArray, forKey: "@folders")
                        
                        self.setEditButton()
                        
                        self.table.reload()
                        
                        self.table.scrollToRow(at: [0,self.categoriesArray.count-1], at: .bottom, animated: true)
                    } else {
                        self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_ATSIGN".localized)
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_SAME".localized)
                    
                    self.table.deselectCell()
                }
            } else {
                self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_ENTER".localized)
                
                self.table.deselectCell()
            }
        }
        
        let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField: UITextField!) -> Void in
            
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapEdit() {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            
            searchBar.enable(true)
            
            editButton.title = "NAV_BUTTON_EDIT".localized
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            searchBar.enable(false)
            
            editButton.title = "NAV_BUTTON_DONE".localized
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
            searchArray = categoriesArray
        } else {
            addButton.isEnabled = false
            editButton.isEnabled = false
            
            showSearchResult()
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
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "ALERT_TITLE_ERROR".localized,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ALERT_BUTTON_CLOSE".localized, style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func setEditButton() {
        if searchBar.text!.isEmpty {
            if categoriesArray.isEmpty {
                editButton.isEnabled = false
                
                searchBar.enable(false)
            } else {
                editButton.isEnabled = true
                
                searchBar.enable(true)
            }
        } else {
            if searchArray.isEmpty {
                editButton.isEnabled = false
            } else {
                editButton.isEnabled = true
            }
            
            searchBar.enable(false)
        }
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        pickedDict.removeAll()
        
        if saveData.object(forKey: "@dictData") != nil {
            let dict = saveData.object(forKey: "@dictData") as! [String: [String]]
            
            for key in categoriesArray {
                var isIncluded = false
                
                for value in dict[key]! {
                    if value.partialMatch(target: searchBar.text!) {
                        isIncluded = true
                        
                        if pickedDict[key] == nil {
                            pickedDict[key] = [value]
                        } else {
                            pickedDict[key]?.append(value)
                        }
                    }
                }
                
                if isIncluded {
                    searchArray.append(key)
                }
            }
        }
    }
    
    func removeAllObject(_ key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func resaveData(_ from: String, to: String) {
        let savedMemoText = saveData.object(forKey: from + "@memo") as! String
        let savedSwitch = saveData.object(forKey: from + "@ison") as! Bool
        let savedDate = saveData.object(forKey: from + "@date") as! Date?
        let savedCheck = saveData.object(forKey: from + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: to + "@memo")
        saveData.set(savedSwitch, forKey: to + "@ison")
        saveData.set(savedDate, forKey: to + "@date")
        saveData.set(savedCheck, forKey: to + "@check")
        
        removeAllObject(from)
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        self.view.endEditing(true)
    }
}
