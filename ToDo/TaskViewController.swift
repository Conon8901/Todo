//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class TaskViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var pickButton: UIBarButtonItem!
    var deleteAllButton: UIBarButtonItem?
    
    var saveData = UserDefaults.standard
    
    var tasksDict = [String: [String]]()
    
    var openedCategory = ""
    var isDataNil = false
    var isToNoteView = false
    var selectedIndex: IndexPath = [0,0]
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        tasksDict = saveData.object(forKey: "dictData") as! [String: [String]]
        openedCategory = variables.shared.currentCategory
        
        navigationItem.title = openedCategory
        
        editButton.title = "NAV_BUTTON_EDIT".localized
        
        deleteAllButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(TaskViewController.deleteAll))
        deleteAllButton?.tintColor = .red
        
        self.navigationItem.leftBarButtonItem = nil
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TaskViewController.putCheckmark))
        table.addGestureRecognizer(longPressRecognizer)
        
        table.tableFooterView = UIView()
        
        setEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if variables.shared.isFromNoteView {
            let index = selectedIndex
            
            table.reloadRows(at: [index], with: .none)
            
            table.selectRow(at: index, animated: false, scrollPosition: .none)
            
            table.deselectCell()
            
            variables.shared.isFromNoteView = false
        }
        
        if variables.shared.isFromMoveView {
            tasksDict = saveData.object(forKey: "dictData") as! [String: [String]]

            table.reload()
            
            variables.shared.isFromMoveView = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        variables.shared.isFromTaskView = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if isToNoteView {
            if let index = table.indexPathForSelectedRow {
                selectedIndex = index
            }
            
            isToNoteView = false
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - NavigationController
    
    @IBAction func addItem() {
        let alert = UIAlertController(
            title: "ALERT_TITLE_ADD".localized,
            message: "ALERT_MESSAGE_ENTER".localized,
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "ALERT_BUTTON_ADD".localized, style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let newItemName = textField.text!
            
            if newItemName.characterExists() {
                if self.tasksDict[self.openedCategory]?.index(of: newItemName) == nil {
                    if !newItemName.contains("@") {
                        let key = self.openedCategory + "@" + newItemName
                        
                        self.tasksDict[self.openedCategory]!.append(newItemName)
                        
                        self.saveData.set(self.tasksDict, forKey: "dictData")
                        self.saveData.set("", forKey: key + "@memo")
                        self.saveData.set(false, forKey: key + "@ison")
                        self.saveData.set(false, forKey: key + "@check")
                        
                        self.setEditButton()
                        
                        if newItemName.partialMatch(variables.shared.searchText) {
                            variables.shared.includingTasks.append(newItemName)
                        }
                        
                        self.table.reload()
                        
                        self.table.scrollToRow(at: [0,self.tasksDict[self.openedCategory]!.count-1], at: .bottom, animated: true)
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
            
            self.navigationItem.leftBarButtonItem = nil
            
            navigationItem.hidesBackButton = false
            
            editButton.title = "NAV_BUTTON_EDIT".localized
            
            addButton.isEnabled = true
            pickButton.isEnabled = true
            
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(TaskViewController.putCheckmark))
            table.addGestureRecognizer(gesture)
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            self.navigationItem.leftBarButtonItem = deleteAllButton
            
            navigationItem.hidesBackButton = true
            
            editButton.title = "NAV_BUTTON_DONE".localized
            
            addButton.isEnabled = false
            pickButton.isEnabled = false
            
            table.gestureRecognizers?.removeAll()
        }
    }
    
    @objc func deleteAll() {
        let alert = UIAlertController(
            title: "ALERT_TITLE_DELETEALL".localized,
            message: "ALERT_MESSAGE_DELETEALL".localized,
            preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "ALERT_BUTTON_DELETE".localized, style: .destructive) { (action: UIAlertAction!) -> Void in
            let tasksArray = self.tasksDict[self.openedCategory]!
            
            tasksArray.forEach({ self.removeData(self.openedCategory + "@" + $0) })
            
            self.tasksDict[self.openedCategory] = []
            
            self.saveData.set(self.tasksDict, forKey: "dictData")
            
            self.editButton.isEnabled = true
            
            self.table.reload()
        }
        
        let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Toolbar
    
    @IBAction func pickItems() {
        let action = UIAlertController(title: "ALERT_TITLE_DATE".localized, message: "ALERT_MESSAGE_DATE".localized, preferredStyle: .actionSheet)
        
        let month = UIAlertAction(title: "ALERT_BUTTON_DATE_MONTH".localized, style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = .month
            
            self.goToDateView()
        })
        
        let week = UIAlertAction(title: "ALERT_BUTTON_DATE_WEEK".localized, style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = .week
            
            self.goToDateView()
        })
        
        let over = UIAlertAction(title: "ALERT_BUTTON_DATE_OVER".localized, style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = .over
            
            self.goToDateView()
        })
        
        let cancel = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel, handler: {
            (action: UIAlertAction!) in
        })
        
        action.addAction(month)
        action.addAction(week)
        action.addAction(over)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tasksDict[openedCategory]!.count == 0 {
            isDataNil = true
            
            return 1
        } else {
            isDataNil = false
            
            return tasksDict[openedCategory]!.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Task")
        
        if isDataNil {
            cell?.textLabel?.text = "CELL_LABEL_ADD_TASK".localized
            cell?.textLabel?.textColor = .gray
            
            cell?.detailTextLabel?.text = ""
            
            cell?.accessoryType = .none
            
            table.allowsSelection = false
        } else {
            let taskName = tasksDict[openedCategory]![indexPath.row]
            let key = openedCategory + "@" + taskName
            
            cell?.textLabel?.text = taskName
            cell?.textLabel?.textColor = .black
            
            cell?.detailTextLabel?.text = saveData.object(forKey: key + "@memo") as! String?
            
            if let isChecked = saveData.object(forKey: key + "@check") as! Bool? {
                if isChecked {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
            }
            
            let pickedArray = variables.shared.includingTasks
            
            if pickedArray.index(of: taskName) != nil {
                cell?.backgroundColor = UIColor(white: 240/255, alpha: 1)
            } else {
                cell?.backgroundColor = .white
            }
            
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
                let newItemName = textField.text!
                
                if newItemName.characterExists() {
                    if self.tasksDict[self.openedCategory]?.index(of: newItemName) == nil {
                        if !newItemName.contains("@") {
                            let oldItemName = self.tasksDict[self.openedCategory]![indexPath.row]
                            
                            let oldKey = self.openedCategory + "@" + oldItemName
                            let newKey = self.openedCategory + "@" + newItemName
                            
                            self.tasksDict[self.openedCategory]?[indexPath.row] = newItemName
                            
                            self.saveData.set(self.tasksDict, forKey: "dictData")
                            self.updateData(oldKey, to: newKey)
                            
                            let oldItemIndex = variables.shared.includingTasks.index(of: oldItemName)
                            if oldItemIndex != nil {
                                variables.shared.includingTasks.remove(at: oldItemIndex!)
                            }
                            
                            if newItemName.partialMatch(variables.shared.searchText) {
                                variables.shared.includingTasks.append(newItemName)
                            }
                            
                            self.table.reload()
                        } else {
                            self.showErrorAlert(message: "ALERT_MESSAGE_ERROR_ATSIGN".localized)
                            
                            self.table.deselectCell()
                        }
                    } else {
                        if newItemName != self.tasksDict[self.openedCategory]?[indexPath.row] {
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
                textField.text = self.tasksDict[self.openedCategory]?[indexPath.row]
                
                textField.clearButtonMode = .whileEditing
            }
            
            alert.addAction(cancelAction)
            alert.addAction(changeAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            variables.shared.currentTask = tasksDict[openedCategory]![indexPath.row]
            
            isToNoteView = true
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Note") as! NoteViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "CELL_BUTTON_DELETE".localized) { (action, index) -> Void in
            if !self.isDataNil {
                let key = self.openedCategory + "@" + self.tasksDict[self.openedCategory]![indexPath.row]
                
                self.tasksDict[self.openedCategory]?.remove(at: indexPath.row)
                
                tableView.reload()
                
                self.saveData.set(self.tasksDict, forKey: "dictData")
                
                self.removeData(key)
                
                self.setEditButton()
            }
            
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "CELL_BUTTON_MOVE".localized) { (action, index) -> Void in
            if !self.isDataNil {
                variables.shared.movingTask = self.tasksDict[self.openedCategory]![indexPath.row]
                
                let nextView = self.storyboard!.instantiateViewController(withIdentifier: "MoveNav") as! UINavigationController
                self.present(nextView, animated: true)
            }
        }
        
        moveButton.backgroundColor = .lightGray
        
        return [deleteButton, moveButton]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = tasksDict[openedCategory]![sourceIndexPath.row]
        
        tasksDict[openedCategory]?.remove(at: sourceIndexPath.row)
        tasksDict[openedCategory]?.insert(movingItem, at: destinationIndexPath.row)
        
        saveData.set(tasksDict, forKey: "dictData")
        
        table.reload()
    }
    
    @objc func putCheckmark(recognizer: UILongPressGestureRecognizer) {
        if let index = table.indexPathForRow(at: recognizer.location(in: table)) {
            if recognizer.state == .began {
                if let cell = table.cellForRow(at: index) {
                    let key = openedCategory + "@" + tasksDict[openedCategory]![index.row] + "@check"
                    
                    if cell.accessoryType == .none {
                        saveData.set(true, forKey: key)
                        
                        cell.accessoryType = .checkmark
                    } else {
                        saveData.set(false, forKey: key)
                        
                        cell.accessoryType = .none
                    }
                }
            }
        }
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
    
    func setEditButton() {
        if tasksDict[openedCategory]!.isEmpty {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
    
    func removeData(_ key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func updateData(_ oldKey: String, to newKey: String) {
        let savedMemo = saveData.object(forKey: oldKey + "@memo") as! String
        let savedSwitch = saveData.object(forKey: oldKey + "@ison") as! Bool
        let savedDate = saveData.object(forKey: oldKey + "@date") as! Date?
        let savedCheck = saveData.object(forKey: oldKey + "@check") as! Bool
        
        saveData.set(savedMemo, forKey: newKey + "@memo")
        saveData.set(savedSwitch, forKey: newKey + "@ison")
        saveData.set(savedDate, forKey: newKey + "@date")
        saveData.set(savedCheck, forKey: newKey + "@check")
        
        removeData(oldKey)
    }
    
    func goToDateView() {
        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "PickNav") as! UINavigationController
        self.present(nextView, animated: true)
    }
}
