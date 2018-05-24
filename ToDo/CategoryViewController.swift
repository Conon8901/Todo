//
//  ViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    
    var saveData = UserDefaults.standard
    
    var tasksDict = [String: [String]]()
    var categoriesArray = [String]()
    var searchArray = [String]()
    var pickedDict = [String: [String]]()
    
    var isDataNil = false
    var selectedIndex: IndexPath = [0,0]
    
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
        
        if let array = saveData.object(forKey: "folders") as! [String]? {
            categoriesArray = array
        }
        
        if let dict = saveData.object(forKey: "dictData") as! [String: [String]]? {
            tasksDict = dict
        }
        
        setTopParts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if variables.shared.isCategoryAdded {
            if let array = saveData.object(forKey: "folders") as! [String]? {
                categoriesArray = array
            }
            
            table.reload()
            
            variables.shared.isCategoryAdded = false
        }
        
        if table.indexPathForSelectedRow == nil {
            table.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)
        }
        
        table.deselectCell()
        
        if variables.shared.isFromTaskView {
            tasksDict =  saveData.object(forKey: "dictData") as! [String: [String]]
            
            pickedDict[variables.shared.currentCategory] = tasksDict[variables.shared.currentCategory]?.filter({ $0.partialMatch(variables.shared.searchText) })
            
            self.table.reloadRows(at: [IndexPath(row: self.searchArray.index(of: variables.shared.currentCategory)!, section: 0)], with: .none)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let index = table.indexPathForSelectedRow {
            selectedIndex = index
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - NavigationController
    
    @IBAction func addItem() {
        searchBar.resignFirstResponder()
        
        let alert = UIAlertController(
            title: "ALERT_TITLE_ADD".localized,
            message: "ALERT_MESSAGE_ENTER".localized,
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "ALERT_BUTTON_ADD".localized, style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let newItemName = textField.text!
            
            if newItemName.characterExists() {
                if self.categoriesArray.index(of: newItemName) == nil {
                    if !newItemName.contains("@") {
                        self.categoriesArray.append(newItemName)
                        
                        self.tasksDict[newItemName] = []
                        
                        self.saveData.set(self.tasksDict, forKey: "dictData")
                        self.saveData.set(self.categoriesArray, forKey: "folders")
                        
                        self.setTopParts()
                        
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
            
            addButton.isEnabled = true
            searchBar.enable(true)
            
            editButton.title = "NAV_BUTTON_EDIT".localized
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            addButton.isEnabled = false
            searchBar.enable(false)
            
            editButton.title = "NAV_BUTTON_DONE".localized
        }
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category")
        
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
                
                let includedFiles = pickedDict[cell!.textLabel!.text!]!.joined(separator: ", ")
                cell?.detailTextLabel?.text = includedFiles
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
                let newCategoryName = textField.text!
                
                if newCategoryName.characterExists() {
                    if self.categoriesArray.index(of: newCategoryName) == nil {
                        if !newCategoryName.contains("@") {
                            let oldCategoryName = self.categoriesArray[indexPath.row]
                            
                            self.categoriesArray[indexPath.row] = newCategoryName
                            
                            self.tasksDict[newCategoryName] = self.tasksDict[oldCategoryName]
                            
                            self.saveData.set(self.tasksDict, forKey: "dictData")
                            self.saveData.set(self.categoriesArray, forKey: "folders")
                            
                            if let filesArray = self.tasksDict[oldCategoryName] {
                                for fileName in filesArray {
                                    let oldKey = oldCategoryName + "@" + fileName
                                    let newKey = newCategoryName + "@" + fileName
                                    
                                    self.updateData(oldKey, to: newKey)
                                }
                            }
                            
                            self.tasksDict.removeValue(forKey: oldCategoryName)
                            
                            self.table.reload()
                        } else {
                            self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_ATSIGN".localized)
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if newCategoryName != self.categoriesArray[indexPath.row] {
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
                variables.shared.currentCategory = categoriesArray[indexPath.row]
            } else {
                variables.shared.currentCategory = searchArray[indexPath.row]
                
                showSearchResult()
                
                variables.shared.includingTasks = pickedDict[searchArray[indexPath.row]]!
                
                variables.shared.isSearched = true
                variables.shared.searchText = searchBar.text!
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Task") as! TaskViewController
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
                let categoryName = categoriesArray[indexPath.row]
                
                tasksDict[categoryName]?.forEach({ removeData(categoryName + "@" + $0 )})
                
                tasksDict.removeValue(forKey: categoryName)
                categoriesArray.remove(at: indexPath.row)
                
                tableView.reload()
                
                self.saveData.set(self.tasksDict, forKey: "dictData")
                self.saveData.set(self.categoriesArray, forKey: "folders")
                
                self.setTopParts()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = categoriesArray[sourceIndexPath.row]
        
        categoriesArray.remove(at: sourceIndexPath.row)
        categoriesArray.insert(movingItem, at: destinationIndexPath.row)
        
        saveData.set(categoriesArray, forKey: "folders")
    }
    
    // MARK: - searchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(CategoryViewController.closeKeyboard))
        self.view.addGestureRecognizer(gesture)
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
    
    // MARK: - Gesture
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        
        self.view.endEditing(true)
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
    
    func setTopParts() {
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
        
        if let dict = saveData.object(forKey: "dictData") as! [String: [String]]? {
            for key in categoriesArray {
                var isIncluded = false
                
                for value in dict[key]! {
                    if value.partialMatch(searchBar.text!) {
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
    
    func removeData(_ key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func updateData(_ oldKey: String, to newKey: String) {
        let savedMemoText = saveData.object(forKey: oldKey + "@memo") as! String
        let savedCheck = saveData.object(forKey: oldKey + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: newKey + "@memo")
        saveData.set(savedCheck, forKey: newKey + "@check")
        
        removeData(oldKey)
    }
}
