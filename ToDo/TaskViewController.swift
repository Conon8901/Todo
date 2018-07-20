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
    var deleteAllButton: UIBarButtonItem?
    
    var saveData = UserDefaults.standard
    
    var checkPuttingRecognizer = UILongPressGestureRecognizer()
    
    var tasksDict = [String: [String]]()
    
    var openedCategory = ""
    var isDataNil = false
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
        
        //読み込み速度の問題で別書き
        checkPuttingRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TaskViewController.putCheckmark))
        
        table.addGestureRecognizer(checkPuttingRecognizer)
        
        table.tableFooterView = UIView()
        
        setEditButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //UX改善
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
                        //UserDefaults準備
                        let key = self.openedCategory + "@" + newItemName
                        
                        //追加
                        self.tasksDict[self.openedCategory]!.append(newItemName)
                        
                        //保存・データ初期設定
                        self.saveData.set(self.tasksDict, forKey: "dictData")
                        self.saveData.set("", forKey: key + "@memo")
                        self.saveData.set(false, forKey: key + "@check")
                        
                        //パーツ整備
                        self.setEditButton()
                        
                        //検索中に該当か判定
                        if variables.shared.isSearched {
                            if newItemName.partialMatch(variables.shared.searchText) {
                                variables.shared.includingTasks.append(newItemName)
                            }
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
        
        let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in }
        
        alert.addTextField { (textField: UITextField!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapEdit() {
        if isEditing {//編集終了後にスクロール可能に
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            
            self.navigationItem.leftBarButtonItem = nil
            
            navigationItem.hidesBackButton = false
            
            editButton.title = "NAV_BUTTON_EDIT".localized
            
            addButton.isEnabled = true
            
            table.addGestureRecognizer(checkPuttingRecognizer)
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            
            self.navigationItem.leftBarButtonItem = deleteAllButton
            
            navigationItem.hidesBackButton = true
            
            editButton.title = "NAV_BUTTON_DONE".localized
            
            addButton.isEnabled = false
            
            table.removeGestureRecognizer(checkPuttingRecognizer)
        }
    }
    
    @objc func deleteAll() {//削除後に編集状態終了
        let alert = UIAlertController(
            title: "ALERT_TITLE_DELETEALL".localized,
            message: "ALERT_MESSAGE_DELETEALL".localized,
            preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "ALERT_BUTTON_DELETE".localized, style: .destructive) { (action: UIAlertAction!) -> Void in
            //カテゴリ内の全タスクを列挙
            let tasksArray = self.tasksDict[self.openedCategory]!
            
            //それぞれデータ削除
            tasksArray.forEach({ self.removeData(self.openedCategory + "@" + $0) })
            
            self.tasksDict[self.openedCategory]?.removeAll()
            
            self.saveData.set(self.tasksDict, forKey: "dictData")
            
            //非編集状態に
            self.tapEdit()
            self.setEditButton()
            
            self.table.reload()
        }
        
        let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
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
            
            let noteText = saveData.object(forKey: key + "@memo") as! String
            
            cell?.detailTextLabel?.text = noteText.regexReplacing(pattern: "\n+", with: " ")
            
            if let isChecked = saveData.object(forKey: key + "@check") as! Bool? {
                if isChecked {
                    cell?.accessoryType = .checkmark
                } else {
                    cell?.accessoryType = .none
                }
            }
            
            table.allowsSelection = true
            
            if variables.shared.isSearched {
                let pickedArray = variables.shared.includingTasks
                
                if pickedArray.index(of: taskName) != nil {
                    cell?.backgroundColor = UIColor(white: 240/255, alpha: 1)
                } else {
                    cell?.backgroundColor = .white
                }
            }
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
                            //旧タスク名取り置き
                            let oldItemName = self.tasksDict[self.openedCategory]![indexPath.row]
                            
                            let oldKey = self.openedCategory + "@" + oldItemName
                            let newKey = self.openedCategory + "@" + newItemName
                            
                            //名称更新
                            self.tasksDict[self.openedCategory]?[indexPath.row] = newItemName
                            
                            self.saveData.set(self.tasksDict, forKey: "dictData")
                            self.updateData(oldKey, to: newKey)
                            
                            //検索中に新旧タスク名が当該如何の判定
                            if variables.shared.isSearched {
                                let oldItemIndex = variables.shared.includingTasks.index(of: oldItemName)
                                if oldItemIndex != nil {
                                    variables.shared.includingTasks.remove(at: oldItemIndex!)
                                }
                                
                                if newItemName.partialMatch(variables.shared.searchText) {
                                    variables.shared.includingTasks.append(newItemName)
                                }
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
            //タスク名保存
            variables.shared.currentTask = tasksDict[openedCategory]![indexPath.row]
            
            if let index = table.indexPathForSelectedRow {
                selectedIndex = index
            }
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Note") as! NoteViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isDataNil {
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "CELL_BUTTON_DELETE".localized) { (action, index) -> Void in
            let key = self.openedCategory + "@" + self.tasksDict[self.openedCategory]![indexPath.row]
            
            self.tasksDict[self.openedCategory]?.remove(at: indexPath.row)
            
            tableView.reload()
            
            self.saveData.set(self.tasksDict, forKey: "dictData")
            
            self.removeData(key)
            
            self.setEditButton()
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "CELL_BUTTON_MOVE".localized) { (action, index) -> Void in
            variables.shared.movingTask = self.tasksDict[self.openedCategory]![indexPath.row]
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "MoveNav") as! UINavigationController
            self.present(nextView, animated: true)
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
        saveData.removeObject(forKey: key + "@check")
    }
    
    func updateData(_ oldKey: String, to newKey: String) {
        let savedMemo = saveData.object(forKey: oldKey + "@memo") as! String
        let savedCheck = saveData.object(forKey: oldKey + "@check") as! Bool
        
        saveData.set(savedMemo, forKey: newKey + "@memo")
        saveData.set(savedCheck, forKey: newKey + "@check")
        
        removeData(oldKey)
    }
}
