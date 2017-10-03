//
//  FileViewController.swift
//  ToDo
//
//  Created by 黒岩修 on 2017/06/03.
//  Copyright © 2017年 黒岩修. All rights reserved.
//

import UIKit

class FileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // MARK: - Declare
    
    @IBOutlet var table: UITableView!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchbar: UISearchBar!
    @IBOutlet var navtitle: UIButton!
    
    var saveData = UserDefaults.standard
    
    var showDict = [String:Array<String>]()
    var searchArray = [String]()
    var addArray = [String]()
    
    var openedFolder = ""
    
    var sameName = false
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        if saveData.object(forKey: "@ToDoList") != nil {
            showDict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
        } else {
            self.saveData.set(self.showDict, forKey: "@TodoList")
        }
        
        openedFolder = saveData.object(forKey: "@move") as! String
        
        checkIsArrayIsEmpty()
        
        if showDict[openedFolder] != nil {
            searchArray = showDict[openedFolder]!
        }
        
        if showDict[openedFolder] == nil {
            showDict[openedFolder] = []
        }
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        let partial = NSLocalizedString("部分", comment: "")
        let exact = NSLocalizedString("完全", comment: "")
        let forward = NSLocalizedString("前方", comment: "")
        let backward = NSLocalizedString("後方", comment: "")
        
        searchbar.scopeButtonTitles = [partial, exact, forward, backward]
        
        editButton.title = NSLocalizedString("編集", comment: "")
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: openedFolder, style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navtitle.setTitle(openedFolder, for: .normal)
        
        if saveData.object(forKey: "@fromListView") != nil{
            showDict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
            saveData.removeObject(forKey: "@fromListView")
        }
        
        table.reloadData()
        
        if showDict[openedFolder]?.count != 0 {
            navtitle.isEnabled = true
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.allRemove(_:)))
            self.navtitle.addGestureRecognizer(longPressGesture)
        } else {
            navtitle.isEnabled = false
            self.navtitle.gestureRecognizers?.removeAll()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != "" {
            return searchArray.count
        } else {
            if showDict[openedFolder] != nil {
                return showDict[openedFolder]!.count
            } else {
                return 0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        if searchbar.text != "" {
            cell?.textLabel?.text = searchArray[indexPath.row]
            
            let fileName = searchArray[indexPath.row]
            if let subtitle = saveData.object(forKey: openedFolder+"@"+fileName) as! String? {
                cell?.detailTextLabel?.text = subtitle
            }
        } else {
            cell?.textLabel?.text = showDict[openedFolder]?[indexPath.row]
            
            let fileName = showDict[openedFolder]?[indexPath.row]
            if let subtitle = saveData.object(forKey: openedFolder+"@"+fileName!) as! String? {
                cell?.detailTextLabel?.text = subtitle
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isEditing {
            edit(indexPath: indexPath)
        } else {
            if searchbar.text == "" {
                saveData.set(showDict[openedFolder]![indexPath.row], forKey: "@memo")
            } else {
                saveData.set(searchArray[indexPath.row], forKey: "@memo")
            }
            
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Memo") as! MemoViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("削除", comment: "")) { (action, index) -> Void in
            if self.searchbar.text == "" {
                let key = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[indexPath.row])!
                self.removeAllObject(key: key)
                
                self.showDict[self.openedFolder]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                self.saveData.set(self.showDict, forKey: "@ToDoList")
                
                if self.showDict[self.openedFolder]?.count == 0 {
                    self.navtitle.isEnabled = false
                    self.navtitle.gestureRecognizers?.removeAll()
                }
            } else {
                let key = self.openedFolder+"@"+self.searchArray[indexPath.row]
                self.removeAllObject(key: key)
                
                self.showDict[self.openedFolder]?.remove(at: (self.showDict[self.openedFolder]?.index(of: self.searchArray[indexPath.row])!)!)
                self.searchArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                self.saveData.set(self.showDict, forKey: "@ToDoList")
                
                if self.searchArray.count == 0 {
                    self.navtitle.isEnabled = false
                    self.navtitle.gestureRecognizers?.removeAll()
                }
            }
            
            if self.showDict[self.openedFolder] != nil {
                if (self.showDict[self.openedFolder]?.count)! < 11 {
                    let coordinates = CGPoint(x: 0, y: -64)
                    self.table.setContentOffset(coordinates, animated: true)
                }
            } else {
                let coordinates = CGPoint(x: 0, y: -64)
                self.table.setContentOffset(coordinates, animated: true)
            }
            
            self.checkIsArrayIsEmpty()
        }
        
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("移動", comment: "")) { (action, index) -> Void in
            if self.searchbar.text == "" {
                self.saveData.set(self.showDict[self.openedFolder]?[indexPath.row], forKey: "@movingfile")
            } else {
                self.saveData.set(self.searchArray[indexPath.row], forKey: "@movingfile")
            }
            
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "List") as! ListViewController
            self.present(nextView, animated: true)
        }
        
        moveButton.backgroundColor = .lightGray
     
        return [deleteButton, moveButton]
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFile = showDict[openedFolder]?[sourceIndexPath.row]
        showDict[openedFolder]?.remove(at: sourceIndexPath.row)
        showDict[openedFolder]?.insert(movingFile!, at: destinationIndexPath.row)
        saveData.set(showDict, forKey: "@ToDoList")
        table.reloadData()
    }
    
    @IBAction func add(sender: AnyObject) {
        let alert = UIAlertController(title: NSLocalizedString("追加", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: CharacterSet.whitespaces).joined() == ""
            
            if isBlank {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            } else {
                self.sameName = false
                
                if self.showDict[self.openedFolder]?.isEmpty == false {
                    for i in 0...(self.showDict[self.openedFolder]?.count)!-1 {
                        if self.showDict[self.openedFolder]?[i] == textField.text! {
                            self.sameName = true
                        }
                    }
                }
                
                if self.sameName {
                    self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                    
                    self.deselect()
                } else {
                    if (textField.text?.contains("@"))! {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    } else {
                        if self.saveData.object(forKey: "@ToDoList") != nil {
                            self.showDict = self.saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
                        }
                        
                        if let dict = self.showDict[self.openedFolder] {
                            self.addArray = dict
                        }
                        
                        self.addArray.append(textField.text!)
                        self.showDict[self.openedFolder] = self.addArray
                        
                        self.saveData.set(self.showDict, forKey: "@ToDoList")
                        
                        self.saveData.synchronize()
                        self.table.reloadData()
                        
                        self.checkIsArrayIsEmpty()
                        
                        if self.searchbar.text == "" {
                            if (self.showDict[self.openedFolder]?.count)! >= 11 {
                                let coordinates = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                                self.table.setContentOffset(coordinates, animated: true)
                            }
                        } else {
                            if self.searchArray.count >= 11 {
                                let coordinates = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                                self.table.setContentOffset(coordinates, animated: true)
                            }
                            
                            self.search()
                            self.table.reloadData()
                        }
                        
                        self.navtitle.isEnabled = true
                        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.allRemove(_:)))
                        self.navtitle.addGestureRecognizer(longPressGesture)
                    }
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func edit(indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("名称変更", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("変更", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: CharacterSet.whitespaces).joined() == ""
            
            if isBlank {
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                
                self.deselect()
            } else {
                self.sameName = false
                for i in 0...(self.showDict[self.openedFolder]?.count)!-1 {
                    if self.showDict[self.openedFolder]?[i] == textField.text! {
                        self.sameName = true
                    }
                }
                
                if self.sameName, textField.text != self.showDict[self.openedFolder]?[indexPath.row] {
                    self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                    
                    self.deselect()
                } else {
                    if (textField.text?.contains("@"))! {
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    } else {
                        if self.searchbar.text == "" {
                            
                            let formerkey = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[indexPath.row])!
                            let laterkey = self.openedFolder+"@"+textField.text!
                            
                            self.resave(formerkey: formerkey, laterkey: laterkey)
                            
                            self.showDict[self.openedFolder]?[indexPath.row] = textField.text!
                            
                            self.saveData.set(self.showDict, forKey: "@ToDoList")
                        } else {
                            let fileName = self.searchArray[indexPath.row]
                            
                            let formerkey = self.openedFolder+"@"+self.searchArray[indexPath.row]
                            let laterkey = self.openedFolder+"@"+textField.text!
                            
                            self.resave(formerkey: formerkey, laterkey: laterkey)
                            
                            self.searchArray[indexPath.row] = textField.text!
                            
                            let index = self.showDict[self.openedFolder]?.index(of: fileName)
                            self.showDict[self.openedFolder]?[index!] = textField.text!
                            
                            self.saveData.set(self.showDict, forKey: "@ToDoList")
                            
                            self.search()
                            self.table.reloadData()
                        }
                        
                        self.table.reloadData()
                    }
                }
            }
            
            self.saveData.set(self.showDict, forKey: "@ToDoList")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            if self.searchbar.text == "" {
                textField.text = self.showDict[self.openedFolder]?[indexPath.row]
            } else {
                textField.text = self.searchArray[indexPath.row]
            }
            textField.textAlignment = .left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func tapEdit(sender: AnyObject) {
        if isEditing {
            super.setEditing(false, animated: true)
            table.setEditing(false, animated: true)
            editButton.title = NSLocalizedString("編集", comment: "")
            navigationItem.hidesBackButton = false
        } else {
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            editButton.title = NSLocalizedString("完了", comment: "")
            navigationItem.hidesBackButton = true
        }
    }
    
    func allRemove(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let alert = UIAlertController(title: NSLocalizedString("全削除", comment: ""), message: NSLocalizedString("本当によろしいですか？\nこのフォルダの全ファイルを削除します", comment: ""), preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "OK", style: .destructive) { (action:UIAlertAction!) -> Void in
                if self.showDict[self.openedFolder]?.count != nil {
                    let filescount = (self.showDict[self.openedFolder]?.count)!
                    if filescount != 0 {
                        for i in 0...filescount-1 {
                            let key = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[i])!
                            self.removeAllObject(key: key)
                        }
                        
                        self.showDict[self.openedFolder] = []
                        self.searchArray = []
                        
                        self.saveData.set(self.showDict, forKey: "@ToDoList")
                        
                        self.table.reloadData()
                        
                        self.editButton.isEnabled = false
                        
                        self.navtitle.isEnabled = false
                        self.navtitle.gestureRecognizers?.removeAll()
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - SearchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }

    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchbar.text == "" {
            searchArray.removeAll()
            searchArray = showDict[openedFolder]!
        } else {
            search()
        }
        
        table.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.text != ""{
            search()
            table.reloadData()
            searchBar.becomeFirstResponder()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        table.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if table.contentOffset.y >= -64 {
            searchbar.endEditing(true)
        }
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("エラー", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func checkIsArrayIsEmpty() {
        let numberOfFiles: Int? = showDict[openedFolder]?.count
        if numberOfFiles != nil {
            if numberOfFiles! == 0 {
                editButton.isEnabled = false
            } else {
                editButton.isEnabled = true
            }
        } else {
            editButton.isEnabled = false
        }
    }
    
    func deselect() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    func removeAllObject(key: String) {
        saveData.removeObject(forKey: key)
        saveData.removeObject(forKey: key+"@ison")
        saveData.removeObject(forKey: key+"@")
        saveData.removeObject(forKey: key+"@@")
    }
    
    func search() {
        searchArray.removeAll()
        
        for fileName in showDict[openedFolder]! {
            switch searchbar.selectedScopeButtonIndex {
            case 0:
                if fileName.lowercased(with: NSLocale.current).contains(searchbar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(fileName)
                }
            case 1:
                if fileName.lowercased(with: NSLocale.current) == searchbar.text!.lowercased(with: NSLocale.current) {
                    searchArray.append(fileName)
                }
            case 2:
                if fileName.lowercased(with: NSLocale.current).hasPrefix(searchbar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(fileName)
                }
            case 3:
                if fileName.lowercased(with: NSLocale.current).hasSuffix(searchbar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(fileName)
                }
            default:
                break
            }
        }
    }
    
    func resave(formerkey: String, laterkey: String) {
        let memoTextView = self.saveData.object(forKey: formerkey) as! String?
        let dateSwitch = self.saveData.object(forKey: formerkey+"@ison") as! Bool?
        let dateField = self.saveData.object(forKey: formerkey+"@") as! String?
        let datePicker = self.saveData.object(forKey: formerkey+"@@") as! Date?
        
        if memoTextView != nil {
            self.saveData.set(memoTextView!, forKey: laterkey)
            self.saveData.removeObject(forKey: formerkey)
        }
        if dateSwitch != nil {
            self.saveData.set(dateSwitch!, forKey: laterkey+"@ison")
            self.saveData.removeObject(forKey: formerkey+"@ison")
        }
        if dateField != nil {
            self.saveData.set(dateField!, forKey: laterkey+"@")
            self.saveData.removeObject(forKey: formerkey+"@")
        }
        if datePicker != nil {
            self.saveData.set(datePicker!, forKey: laterkey+"@@")
            self.saveData.removeObject(forKey: formerkey+"@@")
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
