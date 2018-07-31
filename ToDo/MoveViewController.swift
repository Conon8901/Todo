//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class MoveViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    
    var saveData = UserDefaults.standard
    
    var tasksDict = [String: [String]]()
    var categoriesArray = [String]()
    
    var preCategory = ""
    var movingTask = ""
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        tasksDict = saveData.object(forKey: "dictData") as! [String: [String]]
        categoriesArray = saveData.object(forKey: "folders") as! [String]
        
        preCategory = variables.shared.currentCategory
        movingTask = variables.shared.movingTask
        
        navigationItem.title = "NAV_TITLE_CATEGORY".localized
        
        table.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        variables.shared.isFromMoveView = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - NavigationController
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addItem() {
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
                        
                        //ファイル作成
                        self.tasksDict[newItemName] = []
                        
                        self.saveData.set(self.tasksDict, forKey: "dictData")
                        self.saveData.set(self.categoriesArray, forKey: "folders")
                        
                        self.table.reload()
                        
                        self.table.scrollToRow(at: [0,self.tasksDict.keys.count-1], at: .bottom, animated: true)
                        
                        //記録
                        variables.shared.isCategoryAddedInMoveView = true
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
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Move")
        
        cell?.textLabel?.text = categoriesArray[indexPath.row]
        
        if cell?.textLabel?.text == preCategory {
            cell?.selectionStyle = .none
            
            cell?.textLabel?.textColor = .lightGray
        } else {
            cell?.selectionStyle = .default
            
            cell?.textLabel?.textColor = .black
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if categoriesArray[indexPath.row] != preCategory {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let applicableIndex = tasksDict[categoriesArray[indexPath.row]]!.index(of: movingTask)
        
        if applicableIndex == nil {
            moveTask(indexPath)
        } else {
            let alert = UIAlertController(
                title: "ALERT_TITLE_REPLACE".localized,
                message: "ALERT_MESSAGE_ERROR_SAME".localized,
                preferredStyle: .alert)
            
            let replaceAction = UIAlertAction(title: "ALERT_BUTTON_REPLACE".localized, style: .default) { (action: UIAlertAction!) -> Void in
                self.tasksDict[self.categoriesArray[indexPath.row]]!.remove(at: applicableIndex!)
                
                //もともとあったタスクのメモは上書きされてるので削除は不要
                self.moveTask(indexPath)
            }
            
            let cancelAction = UIAlertAction(title: "ALERT_BUTTON_CANCEL".localized, style: .cancel) { (action: UIAlertAction!) -> Void in
                self.table.deselectCell()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(replaceAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Methods
    
    func moveTask(_ indexPath: IndexPath) {
        let oldKey = preCategory + "@" + movingTask
        let newKey = categoriesArray[indexPath.row] + "@" + movingTask
        
        //新カテゴリに追加
        tasksDict[categoriesArray[indexPath.row]]!.append(movingTask)
        
        //旧カテゴリから削除
        let index = tasksDict[preCategory]!.index(of: movingTask)!
        tasksDict[preCategory]?.remove(at: index)
        
        saveData.set(tasksDict, forKey: "dictData")
        
        updateData(oldKey, to: newKey)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "ALERT_TITLE_ERROR".localized,
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "ALERT_BUTTON_CLOSE".localized, style: .default))
        
        self.present(alert, animated: true, completion: nil)
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
