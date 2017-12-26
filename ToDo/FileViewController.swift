//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var pickByDateButton: UIBarButtonItem!
    
    var deleteAllButton: UIBarButtonItem?
    
    var saveData = UserDefaults.standard
    
    var filesDict = [String: [String]]()
    
    var openedFolder = ""
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.setUp()
        
        filesDict = saveData.object(forKey: "@dictData") as! [String: [String]]
        
        openedFolder = saveData.object(forKey: "@folderName") as! String
        
        editButton.title = NSLocalizedString("NAV_BUTTON_EDIT", comment: "")
        
        deleteAllButton?.title = NSLocalizedString("ALERT_TITLE_DELETEALL", comment: "")
        deleteAllButton?.isEnabled = true
        deleteAllButton?.tintColor = .white
        
        deleteAllButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(FileViewController.deleteAll))
        
        self.navigationItem.leftBarButtonItem = nil
        
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
        return filesDict[openedFolder]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        var fileName = ""
        var key = ""
        
        fileName = filesDict[openedFolder]![indexPath.row]
        
        key = openedFolder + "@" + fileName
        
        cell?.textLabel?.text = fileName
        
        cell?.detailTextLabel?.text = saveData.object(forKey: key + "@memo") as! String?
        
        if let isChecked = saveData.object(forKey: key + "@check") as! Bool? {
            if isChecked {
                cell?.accessoryType = .checkmark
            } else {
                cell?.accessoryType = .none
            }
        }
        
        let searcharray = variables.shared.includingFiles
        
        if searcharray.index(of: fileName) != nil {
            cell?.backgroundColor = UIColor(white: 224/255, alpha: 1)
        } else {
            cell?.backgroundColor = .white
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
                            var preKey = ""
                            var postKey = ""
                            
                            preKey = self.openedFolder + "@" + self.filesDict[self.openedFolder]![indexPath.row]
                            postKey = self.openedFolder + "@" + textField.text!
                            
                            self.filesDict[self.openedFolder]?[indexPath.row] = textField.text!
                            
                            self.saveData.set(self.filesDict, forKey: "@dictData")
                            
                            self.resaveDate(pre: preKey, post: postKey)
                            
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
                textField.text = self.filesDict[self.openedFolder]?[indexPath.row]
                
                textField.textAlignment = .left
            }
            
            alert.addAction(cancelAction)
            alert.addAction(changeAction)
            
            present(alert, animated: true, completion: nil)
        } else {
            saveData.set(filesDict[openedFolder]![indexPath.row], forKey: "@fileName")
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Memo") as! MemoViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("CELL_DELETE", comment: "")) { (action, index) -> Void in
            var key = ""
            
            key = self.openedFolder + "@" + self.filesDict[self.openedFolder]![indexPath.row]
            
            self.filesDict[self.openedFolder]?.remove(at: indexPath.row)
            
            tableView.reloadData()
            
            self.saveData.set(self.filesDict, forKey: "@dictData")
            
            self.removeAllObject(key: key)
            
            self.checkIsArrayEmpty()
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("CELL_MOVE", comment: "")) { (action, index) -> Void in
            variables.shared.movingFileName = self.filesDict[self.openedFolder]![indexPath.row]
            
            let nextView = self.storyboard!.instantiateViewController(withIdentifier: "List") as! ListViewController
            self.present(nextView, animated: true)
        }
        
        moveButton.backgroundColor = .lightGray
        
        return [deleteButton, moveButton]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingItem = filesDict[openedFolder]![sourceIndexPath.row]
        
        filesDict[openedFolder]?.remove(at: sourceIndexPath.row)
        filesDict[openedFolder]?.insert(movingItem, at: destinationIndexPath.row)
        
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
                        
                        self.saveData.set(self.filesDict, forKey: "@dictData")
                        
                        self.checkIsArrayEmpty()
                        
                        self.table.reloadData()
                        
                        self.table.scrollToRow(at: [0,self.filesDict[self.openedFolder]!.count-1], at: .bottom, animated: true)
                        
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
                        saveData.set(true, forKey: openedFolder + "@" + filesDict[openedFolder]![indexPath!.row] + "@check")
                        
                        cell.accessoryType = .checkmark
                    } else {
                        saveData.set(false, forKey: openedFolder + "@" + filesDict[openedFolder]![indexPath!.row] + "@check")
                        
                        cell.accessoryType = .none
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
                files.forEach({ self.removeAllObject(key: self.openedFolder + "@" + $0) })
                
                self.filesDict[self.openedFolder] = []
                
                self.saveData.set(self.filesDict, forKey: "@dictData")
                
                self.editButton.isEnabled = true
                
                self.table.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel) { (action: UIAlertAction!) -> Void in
        }
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Toolbar
    
    @IBAction func pickByDate() {
        var tmpArray = [String]()
        
        let action = UIAlertController(title: NSLocalizedString("ALERT_TITLE_DATE", comment: ""), message: NSLocalizedString("ALERT_MESSAGE_DATE", comment: ""), preferredStyle: .actionSheet)
        
        let year = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DATE_YEAR", comment: ""), style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = NSLocalizedString("ALERT_BUTTON_DATE_YEAR", comment: "")
            
            for file in self.filesDict[self.openedFolder]! {
                let key = self.openedFolder + "@" + file + "@date"
                if let date = self.saveData.object(forKey: key) as! Date? {
                    if date.timeIntervalSinceNow < 60*60*24*365 {
                        tmpArray.append(file)
                    }
                }
            }
            
            variables.shared.dateArray = tmpArray
            
            self.modalToDate()
        })
        
        let halfYear = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DATE_HALF", comment: ""), style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = NSLocalizedString("ALERT_BUTTON_DATE_HALF", comment: "")
            
            for file in self.filesDict[self.openedFolder]! {
                let key = self.openedFolder + "@" + file + "@date"
                if let date = self.saveData.object(forKey: key) as! Date? {
                    if date.timeIntervalSinceNow < 60*60*24*183 {
                        tmpArray.append(file)
                    }
                }
            }
            
            variables.shared.dateArray = tmpArray
            
            self.modalToDate()
        })
        
        let month = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DATE_MONTH", comment: ""), style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = NSLocalizedString("ALERT_BUTTON_DATE_MONTH", comment: "")
            
            for file in self.filesDict[self.openedFolder]! {
                let key = self.openedFolder + "@" + file + "@date"
                if let date = self.saveData.object(forKey: key) as! Date? {
                    if date.timeIntervalSinceNow < 60*60*24*30 {
                        tmpArray.append(file)
                    }
                }
            }
            
            variables.shared.dateArray = tmpArray
            
            self.modalToDate()
        })
        
        let week = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DATE_WEEK", comment: ""), style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = NSLocalizedString("ALERT_BUTTON_DATE_WEEK", comment: "")
            
            for file in self.filesDict[self.openedFolder]! {
                let key = self.openedFolder + "@" + file + "@date"
                if let date = self.saveData.object(forKey: key) as! Date? {
                    if date.timeIntervalSinceNow < 60*60*24*7 {
                        tmpArray.append(file)
                    }
                }
            }
            
            variables.shared.dateArray = tmpArray
            
            self.modalToDate()
        })
        
        let finished = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_DATE_OVER", comment: ""), style: .default, handler: {
            (action: UIAlertAction!) in
            variables.shared.condition = NSLocalizedString("ALERT_BUTTON_DATE_OVER", comment: "")
            
            for file in self.filesDict[self.openedFolder]! {
                let key = self.openedFolder + "@" + file + "@date"
                if let date = self.saveData.object(forKey: key) as! Date? {
                    if date.timeIntervalSinceNow < 0 {
                        tmpArray.append(file)
                    }
                }
            }
            
            variables.shared.dateArray = tmpArray
            
            self.modalToDate()
        })
        
        let cancel = UIAlertAction(title: NSLocalizedString("ALERT_BUTTON_CANCEL", comment: ""), style: .cancel, handler: {
            (action: UIAlertAction!) in
            
        })
        
        action.addAction(year)
        action.addAction(halfYear)
        action.addAction(month)
        action.addAction(week)
        action.addAction(finished)
        action.addAction(cancel)
        
        self.present(action, animated: true, completion: nil)
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
    
    func checkIsArrayEmpty() {
        if filesDict[openedFolder]!.isEmpty {
            editButton.isEnabled = false
        } else {
            editButton.isEnabled = true
        }
    }
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key + "@memo")
        saveData.removeObject(forKey: key + "@ison")
        saveData.removeObject(forKey: key + "@date")
        saveData.removeObject(forKey: key + "@check")
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
    
    func modalToDate() {
        let nextView = self.storyboard!.instantiateViewController(withIdentifier: "Date") as! UINavigationController
        self.present(nextView, animated: true)
    }
    
    // MARK: - Others
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
