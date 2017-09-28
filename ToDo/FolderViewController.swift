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
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var searchbar: UISearchBar!
    
    var saveData = UserDefaults.standard
    
    var folderNameArray = [String]()
    var addNameArray = [String]()
    var searchArray = [String]()
    var deleteDict = [String:Array<String>]()
    var editDict = [String:Array<String>]()
    
    var edit = false
    var sameName = false
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        table.keyboardDismissMode = .interactive
        table.allowsSelectionDuringEditing = true
        
        editButton.title = NSLocalizedString("編集", comment: "")
        
        navigationItem.title = NSLocalizedString("フォルダ", comment: "")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if saveData.object(forKey: "@folder") != nil{
            folderNameArray = saveData.object(forKey: "@folder") as! [String]
        }else{
            self.saveData.set(self.folderNameArray, forKey: "@folder")
        }
        
        if saveData.object(forKey: "@ToDoList") != nil{
            editDict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
        }else{
            self.saveData.set(self.editDict, forKey: "@ToDoList")
        }
        
        search()
        
        table.reloadData()
        
        deselect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - SearchBar
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchbar.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchArray.removeAll()
        
        if(searchbar.text == "") {
            searchArray = folderNameArray
        }else{
            for data in folderNameArray {
                if data.lowercased(with: NSLocale.current).contains(searchbar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(data)
                }
            }
        }
        
        table.reloadData()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if table.contentOffset.y >= -64{
            searchbar.endEditing(true)
        }
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != ""{
            return searchArray.count
        }else{
            return folderNameArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Folder")
        
        if searchbar.text == ""{
            cell?.textLabel?.text = folderNameArray[indexPath.row]
        }else{
            cell?.textLabel?.text = searchArray[indexPath.row]
        }
        
        cell?.textLabel?.numberOfLines = 0
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edit {
            edit(indexPath: indexPath)
        }else{
            if searchbar.text == "" {
                saveData.set(folderNameArray[indexPath.row], forKey: "@move")
            }else{
                saveData.set(searchArray[indexPath.row], forKey: "@move")
            }
            
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "File") as! FileViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
            
            if(searchbar.text == "") {
                if deleteDict[folderNameArray[indexPath.row]] != nil{
                    for file in deleteDict[folderNameArray[indexPath.row]]!{
                        let key = folderNameArray[indexPath.row]+"@"+file
                        saveData.removeObject(forKey: key)
                        saveData.removeObject(forKey: key+"@ison")
                        saveData.removeObject(forKey: key+"@")
                        saveData.removeObject(forKey: key+"@@")
                    }
                }
                
                deleteDict[String(folderNameArray[indexPath.row])] = nil
                self.saveData.set(self.deleteDict, forKey: "@ToDoList")
                folderNameArray.remove(at: indexPath.row)
            }else{
                if deleteDict[searchArray[indexPath.row]] != nil{
                    for file in deleteDict[searchArray[indexPath.row]]!{
                        let key = searchArray[indexPath.row]+"@"+file
                        saveData.removeObject(forKey: key)
                        saveData.removeObject(forKey: key+"@ison")
                        saveData.removeObject(forKey: key+"@")
                        saveData.removeObject(forKey: key+"@@")
                    }
                }
                
                deleteDict[searchArray[indexPath.row]] = nil
                self.saveData.set(self.deleteDict, forKey: "@ToDoList")
                folderNameArray.remove(at: folderNameArray.index(of: searchArray[indexPath.row])!)
                searchArray.remove(at: indexPath.row)
            }
            
            tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
            
            saveData.set(self.folderNameArray, forKey: "@folder")
            
            search()
            
            if folderNameArray.isEmpty{
                let coordinates = CGPoint(x: 0, y: -64)
                self.table.setContentOffset(coordinates, animated: true)
            }else{
                if self.folderNameArray.count < 11{
                    let coordinates = CGPoint(x: 0, y: -64)
                    self.table.setContentOffset(coordinates, animated: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingFolder = folderNameArray[sourceIndexPath.row]
        folderNameArray.remove(at: sourceIndexPath.row)
        folderNameArray.insert(movingFolder, at: destinationIndexPath.row)
        saveData.set(folderNameArray, forKey:"@folder")
    }
    
    @IBAction func add(sender: AnyObject) {
        let alert = UIAlertController(title: NSLocalizedString("フォルダ追加", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: CharacterSet.whitespaces).joined() == ""
            
            if isBlank{
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            }else{
                self.sameName = false
                if self.folderNameArray.count != 0{
                    for i in 0...self.folderNameArray.count-1{
                        if self.folderNameArray[i] == textField.text!{
                            self.sameName = true
                        }
                    }
                }
                
                if self.sameName{
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                }else{
                    if (textField.text?.contains("@"))!{
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    }else{
                        self.folderNameArray.append(textField.text!)
                        self.table.reloadData()
                        
                        self.saveData.set(self.folderNameArray, forKey: "@folder")
                        self.saveData.synchronize()
                        
                        self.search()
                        
                        if self.folderNameArray.count >= 11{
                            let coordinates = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                            self.table.setContentOffset(coordinates, animated: true)
                        }
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
        var beforetitle = ""
        
        let alert = UIAlertController(title: NSLocalizedString("名称変更", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: NSLocalizedString("変更", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let isBlank = textField.text!.components(separatedBy: CharacterSet.whitespaces).joined() == ""
            
            if isBlank{
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                
                self.deselect()
            }else{
                self.sameName = false
                
                for i in 0...self.folderNameArray.count-1{
                    if self.folderNameArray[i] == textField.text!{
                        self.sameName = true
                    }
                }
                
                if self.sameName, textField.text != self.folderNameArray[indexPath.row]{
                    self.showalert(message: NSLocalizedString("同名のフォルダがあります", comment: ""))
                    
                    self.deselect()
                }else{
                    if (textField.text?.contains("@"))!{
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    }else{
                        if self.searchbar.text == ""{
                            beforetitle = self.folderNameArray[indexPath.row]
                            
                            var dict = self.saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
                            
                            var contentsOfFolder = [String]()
                            
                            if let content = dict[self.folderNameArray[indexPath.row]]{
                                if !content.isEmpty{
                                    for i in 0...content.count-1{
                                        let formerkey = self.folderNameArray[indexPath.row]+"@"+content[i]
                                        
                                        let memoTextView = self.saveData.object(forKey: formerkey) as? String
                                        let dateSwitch = self.saveData.object(forKey: formerkey+"@ison") as? Bool
                                        let dateField = self.saveData.object(forKey: formerkey+"@") as? String
                                        let datePicker = self.saveData.object(forKey: formerkey+"@@") as? Date
                                        
                                        let laterkey = textField.text!+"@"+content[i]
                                        
                                        if memoTextView != nil{
                                            self.saveData.set(memoTextView!, forKey: laterkey)
                                        }
                                        if dateSwitch != nil{
                                            self.saveData.set(dateSwitch!, forKey: laterkey+"@ison")
                                        }
                                        if dateField != nil{
                                            self.saveData.set(dateField!, forKey: laterkey+"@")
                                        }
                                        if datePicker != nil{
                                            self.saveData.set(datePicker!, forKey: laterkey+"@@")
                                        }
                                        
                                        self.saveData.removeObject(forKey: formerkey)
                                        self.saveData.removeObject(forKey: formerkey+"@ison")
                                        self.saveData.removeObject(forKey: formerkey+"@")
                                        self.saveData.removeObject(forKey: formerkey+"@@")
                                    }
                                }
                            }
                            
                            if let content = dict[self.folderNameArray[indexPath.row]]{
                                if !content.isEmpty{
                                    for _ in 0...content.count-1{
                                        contentsOfFolder.append((dict[self.folderNameArray[indexPath.row]]?[0])!)
                                        dict[self.folderNameArray[indexPath.row]]?.remove(at: 0)
                                    }
                                }
                            }
                            
                            self.folderNameArray[indexPath.row] = textField.text!
                            
                            dict[self.folderNameArray[indexPath.row]] = contentsOfFolder
                            
                            dict[beforetitle] = nil
                            
                            self.saveData.set(dict, forKey: "@ToDoList")
                        }else{
                            beforetitle = self.searchArray[indexPath.row]
                            
                            var dict = self.saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
                            
                            let folderName = self.searchArray[indexPath.row]
                            
                            if let content = dict[folderName]{
                                if !content.isEmpty{
                                    for data in content{
                                        let formerkey = folderName+"@"+data
                                        
                                        let memotextview = self.saveData.object(forKey: formerkey) as? String
                                        let dateswitch = self.saveData.object(forKey: formerkey+"@ison") as? Bool
                                        let datefield = self.saveData.object(forKey: formerkey+"@") as? String
                                        let datepicker = self.saveData.object(forKey: formerkey+"@@") as? Date
                                        
                                        let laterkey = textField.text!+"@"+data
                                        
                                        self.saveData.removeObject(forKey: formerkey)
                                        self.saveData.removeObject(forKey: formerkey+"@ison")
                                        self.saveData.removeObject(forKey: formerkey+"@")
                                        self.saveData.removeObject(forKey: formerkey+"@@")
                                        
                                        if memotextview != nil{
                                            self.saveData.set(memotextview!, forKey: laterkey)
                                        }
                                        if dateswitch != nil{
                                            self.saveData.set(dateswitch!, forKey: laterkey+"@ison")
                                        }
                                        if datefield != nil{
                                            self.saveData.set(datefield!, forKey: laterkey+"@")
                                        }
                                        if datepicker != nil{
                                            self.saveData.set(datepicker!, forKey: laterkey+"@@")
                                        }
                                    }
                                }
                            }
                            
                            var contentsOfFolder = [String]()
                            
                            if let content = dict[self.searchArray[indexPath.row]]{
                                if !content.isEmpty{
                                    for _ in 0...content.count-1{
                                        contentsOfFolder.append((dict[self.searchArray[indexPath.row]]?[0])!)
                                        dict[self.searchArray[indexPath.row]]?.remove(at: 0)
                                    }
                                }
                            }
                            
                            let index = self.folderNameArray.index(of: self.searchArray[indexPath.row])
                            
                            self.searchArray[indexPath.row] = textField.text!
                            
                            self.folderNameArray[index!] = textField.text!
                            
                            dict[self.searchArray[indexPath.row]] = contentsOfFolder
                            
                            dict[beforetitle] = nil

                            self.saveData.set(dict, forKey: "@ToDoList")
                        }
                        
                        self.table.reloadData()
                    }
                }
            }
            
            self.saveData.set(self.folderNameArray, forKey: "@folder")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            if self.searchbar.text == ""{
                textField.text = self.folderNameArray[indexPath.row]
            }else{
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
            edit = false
        }else{
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            editButton.title = NSLocalizedString("完了", comment: "")
            edit = true
        }
    }
    
    // MARK: - Method
    
    func showalert(message: String) {
        let alert = UIAlertController(
            title: NSLocalizedString("エラー", comment: ""),
            message: message,
            preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func search() {
        editButton.isEnabled = folderNameArray.isEmpty ? false : true
    }
    
    func deselect() {
        if let indexPathForSelectedRow = self.table.indexPathForSelectedRow {
            self.table.deselectRow(at: indexPathForSelectedRow, animated: true)
        }
    }
    
    // MARK: - Else
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        sender.cancelsTouchesInView = false
        self.view.endEditing(true)
    }
}
