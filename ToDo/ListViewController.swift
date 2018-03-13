//
//  ListViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/09/08.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    
    var saveData = UserDefaults.standard
    
    var tasksDict = [String: [String]]()
    var categoriesArray = [String]()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        categoriesArray = saveData.object(forKey: "@folders") as! [String]
        
        tasksDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        navigationItem.title = "NAV_TITLE_CATEGORY".localized
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        cell?.textLabel?.text = categoriesArray[indexPath.row]
        
        cell?.textLabel?.numberOfLines = 0
        
        if cell?.textLabel?.text == saveData.object(forKey: "@folderName") as! String? {
            cell?.selectionStyle = .none
            
            cell?.textLabel?.textColor = .lightGray
        } else {
            cell?.selectionStyle = .default
            
            cell?.textLabel?.textColor = .black
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let preCategory = saveData.object(forKey: "@folderName") as! String
        
        if categoriesArray[indexPath.row] != preCategory {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskName = variables.shared.movingTaskName
        let taskIndex = tasksDict[categoriesArray[indexPath.row]]!.index(of: taskName)
        
        if taskIndex == nil {
            moveTask(indexPath)
        } else {
            let alert = UIAlertController(
                title: "ALERT_TITLE_REPLACE".localized,
                message: "ALERT_MESSAGE_ERROR_SAME".localized,
                preferredStyle: .alert)
            
            let replaceAction = UIAlertAction(title: "ALERT_BUTTON_REPLACE".localized, style: .default) { (action: UIAlertAction!) -> Void in
                self.tasksDict[self.categoriesArray[indexPath.row]]!.remove(at: taskIndex!)
                
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
    
    func moveTask(_ indexPath: IndexPath) {
        let preCategory = saveData.object(forKey: "@folderName") as! String
        let taskName = variables.shared.movingTaskName
        let preKey = preCategory + "@" + taskName
        let postKey = categoriesArray[indexPath.row] + "@" + taskName
        
        tasksDict[categoriesArray[indexPath.row]]!.append(taskName)
        
        let index = tasksDict[preCategory]!.index(of: taskName)!
        tasksDict[preCategory]?.remove(at: index)
        
        saveData.set(tasksDict, forKey: "@dictData")
        
        resaveData(pre: preKey, post: postKey)
        
        variables.shared.isFromListView = true
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addItem() {
        let alert = UIAlertController(
            title: "ALERT_TITLE_ADD".localized,
            message: "ALERT_MESSAGE_ENTER".localized,
            preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "ALERT_BUTTON_ADD".localized, style: .default) { (action: UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: .whitespaces).joined().isEmpty
            
            if !isBlank {
                if self.categoriesArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.categoriesArray.append(textField.text!)
                        
                        self.tasksDict[textField.text!] = []
                        
                        self.saveData.set(self.tasksDict, forKey: "@dictData")
                        self.saveData.set(self.categoriesArray, forKey: "@folders")
                        
                        self.table.reload()
                        
                        self.table.scrollToRow(at: [0,self.tasksDict.keys.count-1], at: .bottom, animated: true)
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
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(addAction)
        
        present(alert, animated: true, completion: nil)
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
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
    }
    
    func resaveData(pre: String, post: String) {
        let savedMemo = saveData.object(forKey: pre + "@memo") as! String
        let savedSwitch = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let savedCheckmark = saveData.object(forKey: pre + "@check") as! Bool
        
        saveData.set(savedMemo, forKey: post + "@memo")
        saveData.set(savedSwitch, forKey: post + "@ison")
        saveData.set(savedDate, forKey: post + "@date")
        saveData.set(savedCheckmark, forKey: post + "@check")
        
        removeAllObject(key: pre)
    }
    
    // MARK: - Others
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
