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
    var satisfiedDict = [String: [String]]()
    
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
        
        if let selectedIndex = table.indexPathForSelectedRow {
            cellIndex = selectedIndex
        }
        
        table.reload()
        
        if variables.shared.isFromFileView {
            table.selectRow(at: cellIndex, animated: false, scrollPosition: .none)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.table.deselectRow(at: self.cellIndex, animated: true)
                
                variables.shared.isFromFileView = false
            }
            
            searchBar.enable(true)
            
            showSearchResult()
        }
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
            cell?.textLabel?.text = NSLocalizedString("CELL_LABEL_ADD_CATEGORY", comment: "")
            cell?.textLabel?.textColor = .gray
            
            cell?.detailTextLabel?.text = ""
            
            table.allowsSelection = false
        } else {
            if searchBar.text!.isEmpty {
                cell?.textLabel?.text = categoriesArray[indexPath.row]
                
                cell?.detailTextLabel?.text = ""
            } else {
                cell?.textLabel?.text = searchArray[indexPath.row]
                
                var includingFiles = ""
                for files in satisfiedDict[cell!.textLabel!.text!]! {
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
                                    
                                    self.resaveData(pre: preKey, post: postKey)
                                }
                            }
                            
                            self.tasksDict[preCategoryName] = nil
                            
                            self.table.reload()
                        } else {
                            self.showErrorAlert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if textField.text != self.categoriesArray[indexPath.row] {
                            self.showErrorAlert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME", comment: ""))
                        }
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showErrorAlert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ENTER", comment: ""))
                    
                    self.table.deselectCell()
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.table.deselectCell()
            }
            
            alert.addTextField { (textField: UITextField!) -> Void in
                textField.text = self.categoriesArray[indexPath.row]
                
                textField.textAlignment = .left
                
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
                
                variables.shared.includingTasks = satisfiedDict[searchArray[indexPath.row]]!
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
                
                tasksDict[categoryName]?.forEach({ removeAllObject(key: categoryName + "@" + $0 )})
                
                tasksDict[categoryName] = nil
                
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
            title: NSLocalizedString("ALERT_TITLE_ADD", comment: ""),
            message: NSLocalizedString("ALERT_MESSAGE_ENTER", comment: ""),
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_ADD", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
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
                        self.showErrorAlert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showErrorAlert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME", comment: ""))
                    
                    self.table.deselectCell()
                }
            } else {
                self.showErrorAlert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ENTER", comment: ""))
                
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
            
            searchBar.enable(true)
            
            editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            searchBar.enable(false)
            
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
            title: NSLocalizedString("ALERT_TITLE_ERROR", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CLOSE", comment: ""), style: .default))
        
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
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func showSearchResult() {
        searchArray.removeAll()
        satisfiedDict.removeAll()
        
        if saveData.object(forKey: "@dictData") != nil {
            let dict = saveData.object(forKey: "@dictData") as! [String: [String]]
            
            for key in categoriesArray {
                var isIncluding = false
                
                for value in dict[key]! {
                    if value.partialMatch(target: searchBar.text!) {
                        isIncluding = true
                        
                        if satisfiedDict[key] == nil {
                            satisfiedDict[key] = [value]
                        } else {
                            satisfiedDict[key]?.append(value)
                        }
                    }
                }
                
                if isIncluding {
                    searchArray.append(key)
                }
            }
        }
    }
    
    func resaveData(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let savedSwitch = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let savedCheckmark = saveData.object(forKey: pre + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: post + "@memo")
        
        saveData.set(savedSwitch, forKey: post + "@ison")
        
        if savedDate != nil {
            saveData.set(savedDate!, forKey: post + "@date")
        }
        
        saveData.set(savedCheckmark, forKey: post + "@check")
        
        removeAllObject(key: pre)
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
