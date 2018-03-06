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
    
    var filesDict = [String: [String]]()
    
    var listNameArray = [String]()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        listNameArray = saveData.object(forKey: "@folders") as! [String]
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        navigationItem.title = NSLocalizedString("NAV_TITLE_FOLDER", comment: "")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "List")
        
        cell?.textLabel?.text = listNameArray[indexPath.row]
        
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
        let folderName = saveData.object(forKey: "@folderName") as! String
        
        if listNameArray[indexPath.row] != folderName {
            return indexPath
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let preFolderName = saveData.object(forKey: "@folderName") as! String
        let fileName = variables.shared.movingFileName
        
        let preKey = preFolderName + "@" + fileName
        
        let fileIndex = filesDict[listNameArray[indexPath.row]]!.index(of: fileName)
        
        let postKey = listNameArray[indexPath.row] + "@" + fileName
        
        if fileIndex == nil {
            filesDict[listNameArray[indexPath.row]]!.append(fileName)
            
            let index = filesDict[preFolderName]!.index(of: fileName)!
            filesDict[preFolderName]?.remove(at: index)
            
            saveData.set(filesDict, forKey: "@dictData")
            
            resaveDate(pre: preKey, post: postKey)
            
            variables.shared.isFromListView = true
            
            self.dismiss(animated: true, completion: nil)
        } else {
            let alert = UIAlertController(
                title: NSLocalizedString("ALERT_TITLE_REPLACE", comment: ""),
                message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FILE", comment: ""),
                preferredStyle: .alert)
            
            let replaceAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_REPLACE", comment: ""), style: .default) { (action: UIAlertAction!) -> Void in
                self.filesDict[self.listNameArray[indexPath.row]]!.remove(at: fileIndex!)
                self.filesDict[self.listNameArray[indexPath.row]]!.append(fileName)
                
                let index = self.filesDict[preFolderName]!.index(of: fileName)!
                self.filesDict[preFolderName]?.remove(at: index)
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                
                self.resaveDate(pre: preKey, post: postKey)
                
                variables.shared.isFromListView = true
                
                self.dismiss(animated: true, completion: nil)
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
                self.table.deselectCell()
            }
            
            alert.addAction(cancelAction)
            alert.addAction(replaceAction)
            
            present(alert, animated: true, completion: nil)
        }
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
                if self.listNameArray.index(of: textField.text!) == nil {
                    if !textField.text!.contains("@") {
                        self.listNameArray.append(textField.text!)
                        
                        self.filesDict[textField.text!] = []
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        self.saveData.set(self.listNameArray, forKey: "@folders")
                        
                        self.table.reload()
                        
                        self.table.scrollToRow(at: [0,self.filesDict.keys.count-1], at: .bottom, animated: true)
                    } else {
                        self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_ATSIGN", comment: ""))
                        
                        self.table.deselectCell()
                    }
                } else {
                    self.showalert(message: NSLocalizedString("ALERT_MESSAGE_ERROR_SAME_FOLDER", comment: ""))
                    
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
    
    // MARK: - Methods
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("ALERT_TITLE_ERROR", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CLOSE", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func resaveDate(pre: String, post: String) {
        let savedMemoText = saveData.object(forKey: pre + "@memo") as! String
        let savedisShownParts = saveData.object(forKey: pre + "@ison") as! Bool
        let savedDate = saveData.object(forKey: pre + "@date") as! Date?
        let savedisChecked = saveData.object(forKey: pre + "@check") as! Bool
        
        saveData.set(savedMemoText, forKey: post + "@memo")
        saveData.removeObject(forKey: pre + "@memo")
        
        saveData.set(savedisShownParts, forKey: post + "@ison")
        saveData.removeObject(forKey: pre + "@ison")
        
        if savedDate != nil {
            saveData.set(savedDate, forKey: post + "@date")
            saveData.removeObject(forKey: pre + "@date")
        }
        
        saveData.set(savedisChecked, forKey: post + "@check")
        saveData.removeObject(forKey: pre + "@check")
    }
    
    // MARK: - Others
    
    @IBAction func tapCancel() {
        self.dismiss(animated: true, completion: nil)
    }
}
