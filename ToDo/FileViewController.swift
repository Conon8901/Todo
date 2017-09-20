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
    
    let excludes = CharacterSet(charactersIn: "　 ")
    
    var openedFolder = ""
    var addfile = ""
    
    var addArray = [String]()
    var showDict = [String:Array<String>]()
    var searchArray = [String]()
    
    var edit = false
    var sameName = false
    var button = false
    
    // MARK: - Basics
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        
        if saveData.object(forKey: "@ToDoList") != nil{
            showDict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
        }else{
            self.saveData.set(self.showDict, forKey: "@TodoList")
        }
        
        openedFolder = saveData.object(forKey: "@move")! as! String
        
        search()
        
        if showDict[openedFolder] != nil {
            searchArray = showDict[openedFolder]!
        }
        
        searchbar.delegate = self
        searchbar.enablesReturnKeyAutomatically = false
        
        editButton.title = NSLocalizedString("編集", comment: "")
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(FileViewController.allRemove(_:)))
        self.navtitle.addGestureRecognizer(longPressGesture)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: openedFolder, style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navtitle.setTitle(openedFolder, for: .normal)
        showDict = saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
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
            searchArray = showDict[openedFolder]!
        }else{
            for data in showDict[openedFolder]! {
                if data.lowercased(with: NSLocale.current).contains(searchbar.text!.lowercased(with: NSLocale.current)) {
                    searchArray.append(data)
                }
            }
        }
        table.reloadData()
    }
    
    // MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchbar.text != ""{
            return searchArray.count
        }else{
            if showDict[openedFolder] == nil{
                return 0
            }else{
                return showDict[openedFolder]!.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "File")
        
        if searchbar.text != ""{
            cell?.textLabel?.text = searchArray[indexPath.row]
            
            let text = searchArray[indexPath.row]
            if let subtitle = saveData.object(forKey: openedFolder+"@"+text) as! String?{
                cell?.detailTextLabel?.text = subtitle
            }
        }else{
            cell?.textLabel?.text = showDict[openedFolder]?[indexPath.row]
            
            let text = (showDict[openedFolder]?[indexPath.row])!
            if let subtitle = saveData.object(forKey: openedFolder+"@"+text) as! String?{
                cell?.detailTextLabel?.text = subtitle
            }
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if edit {
            edit(indexPath: indexPath)
        }else{
            if(searchbar.text == "") {
                saveData.set(String(showDict[openedFolder]![indexPath.row]), forKey: "@memo")
            }else{
                saveData.set(String(searchArray[indexPath.row]), forKey: "@memo")
            }
            
            let storyboard = self.storyboard!
            let nextView = storyboard.instantiateViewController(withIdentifier: "Memo") as! MemoViewController
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView,canEditRowAt indexPath: IndexPath) -> Bool{
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("削除", comment: "")) { (action, index) -> Void in
     
            if self.searchbar.text == ""{
                
                let key = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[indexPath.row])!
                self.saveData.removeObject(forKey: key)
                self.saveData.removeObject(forKey: key+"@ison")
                self.saveData.removeObject(forKey: key+"@")
                self.saveData.removeObject(forKey: key+"@@")
                
                self.saveData.set("", forKey: self.openedFolder+"@"+(self.showDict[self.openedFolder]?[indexPath.row])!)
                self.showDict[self.openedFolder]?.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                self.saveData.set(self.showDict, forKey: "@ToDoList")
            }else{
                let key = self.openedFolder+"@"+self.searchArray[indexPath.row]
                
                self.saveData.removeObject(forKey: key)
                self.saveData.removeObject(forKey: key+"@ison")
                self.saveData.removeObject(forKey: key+"@")
                self.saveData.removeObject(forKey: key+"@@")
                
                self.saveData.set("", forKey: self.openedFolder+"@"+self.searchArray[indexPath.row])
                self.showDict[self.openedFolder]?.remove(at: (self.showDict[self.openedFolder]?.index(of: self.searchArray[indexPath.row])!)!)
                self.searchArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                self.saveData.set(self.showDict, forKey: "@ToDoList")
            }
            
            if self.showDict[self.openedFolder] != nil{
                if (self.showDict[self.openedFolder]?.count)! < 11{
                    let offset = CGPoint(x: 0, y: -64)
                    self.table.setContentOffset(offset, animated: true)
                }
            }else{
                let offset = CGPoint(x: 0, y: -64)
                self.table.setContentOffset(offset, animated: true)
            }
            
            self.search()
     
        }
        deleteButton.backgroundColor = .red
        
        let moveButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: NSLocalizedString("移動", comment: "")) { (action, index) -> Void in
            
            if self.searchbar.text == ""{
                self.saveData.set(self.showDict[self.openedFolder]?[indexPath.row], forKey: "@movingfile")
            }else{
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
        saveData.setValue(showDict, forKeyPath: "@ToDoList")
        table.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @IBAction func add(sender: AnyObject) {
        let alert = UIAlertController(title: NSLocalizedString("追加", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("追加", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                
                if self.showDict[self.openedFolder]?.isEmpty == false{
                    for i in 0...(self.showDict[self.openedFolder]?.count)!-1{
                        if self.showDict[self.openedFolder]?[i] == textField.text!{
                            self.sameName = true
                        }
                    }
                }
                
                if self.sameName{
                    self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                    
                    self.deselect()
                }else{
                    if (textField.text?.contains("@"))!{
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    }else{
                        if self.saveData.object(forKey: "@ToDoList") != nil{
                            self.showDict = self.saveData.object(forKey: "@ToDoList") as! [String : Array<String>]
                        }
                        
                        if let dict = self.showDict[self.openedFolder] {
                            self.addArray = dict
                        }
                        self.addfile = textField.text!
                        self.addArray.append(self.addfile)
                        self.showDict[self.openedFolder] = self.addArray
                        
                        self.saveData.setValue(self.showDict, forKeyPath: "@ToDoList")
                        
                        self.saveData.set("", forKey: self.openedFolder+"@"+textField.text!)
                        
                        self.saveData.synchronize()
                        self.table.reloadData()
                        
                        self.search()
                        
                        if (self.showDict[self.openedFolder]?.count)! >= 11{
                            let offset = CGPoint(x: 0, y: self.table.contentSize.height-self.table.frame.height)
                            self.table.setContentOffset(offset, animated: true)
                        }
                    }
                }
            }else{
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
            }
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.textAlignment = NSTextAlignment.left
        }
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func edit(indexPath: IndexPath) {
        let alert = UIAlertController(title: NSLocalizedString("名称変更", comment: ""), message: NSLocalizedString("タイトル入力", comment: ""), preferredStyle: .alert)
        let saveAction = UIAlertAction(title: NSLocalizedString("変更", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            let textField = alert.textFields![0] as UITextField
            
            let blank = String(describing: textField.text!).components(separatedBy: self.excludes).joined()
            if blank != ""{
                self.sameName = false
                for i in 0...(self.showDict[self.openedFolder]?.count)!-1{
                    if self.showDict[self.openedFolder]?[i] == textField.text!{
                        self.sameName = true
                    }
                }
                
                if self.sameName, textField.text != self.showDict[self.openedFolder]?[indexPath.row]{
                    self.showalert(message: NSLocalizedString("同名のファイルがあります", comment: ""))
                    
                    self.deselect()
                }else{
                    if (textField.text?.contains("@"))!{
                        self.showalert(message: NSLocalizedString("'@'は使用できません", comment: ""))
                        
                        self.deselect()
                    }else{
                        if self.searchbar.text == ""{
                            
                            let formerkey = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[indexPath.row])!
                            
                            var memotextview: String?
                            var dateswitch: Bool?
                            var datefield: String?
                            var datepicker: Date?
                            
                            if self.saveData.object(forKey: formerkey) != nil{
                                memotextview = self.saveData.object(forKey: formerkey) as? String
                            }
                            if (self.saveData.object(forKey: formerkey+"@ison") != nil){
                                dateswitch = self.saveData.object(forKey: formerkey+"@ison") as? Bool
                            }
                            if (self.saveData.object(forKey: formerkey+"@") != nil){
                                datefield = self.saveData.object(forKey: formerkey+"@") as? String
                            }
                            if (self.saveData.object(forKey: formerkey+"@@") != nil){
                                datepicker = self.saveData.object(forKey: formerkey+"@@") as? Date
                            }
                            
                            let formertext = (self.showDict[self.openedFolder]?[indexPath.row])!
                            
                            self.showDict[self.openedFolder]?[indexPath.row] = textField.text!
                            
                            let revisedtext = (self.showDict[self.openedFolder]?[indexPath.row])!
                            
                            let formermemo = self.saveData.object(forKey: self.openedFolder+"@"+formertext)
                            
                            self.saveData.removeObject(forKey: self.openedFolder+"@"+formertext)
                            self.saveData.set(formermemo, forKey: self.openedFolder+"@"+revisedtext)
                            
                            self.saveData.set(self.showDict, forKey: "@ToDoList")
                            
                            let laterkey = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[indexPath.row])!
                            
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
                        }else{
//////////////////////////////////////////////Dateの書き換え///////////////////////////////////////////////

////////////////////////////////////////////searcharrayに変更/////////////////////////////////////////////
//                            let formertext = (self.showDict[self.openedFolder]?[indexPath.row])!
//                            
//                            self.showDict[self.openedFolder]?[indexPath.row] = textField.text!
//                            
//                            let revisedtext = (self.showDict[self.openedFolder]?[indexPath.row])!
//                            
//                            let formermemo = self.saveData.object(forKey: self.openedFolder+"@"+formertext)
//                            
//                            self.saveData.set("", forKey: self.openedFolder+"@"+formertext)
//                            self.saveData.set(formermemo, forKey: self.openedFolder+"@"+revisedtext)
//                            
//                            self.saveData.set(self.showDict, forKey: "@ToDoList")
                            
                        }
                        
                        self.table.reloadData()
                    }
                }
            }else{
                self.showalert(message: NSLocalizedString("入力してください", comment: ""))
                
                self.deselect()
            }
            
            self.saveData.set(self.showDict, forKey: "@ToDoList")
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            self.deselect()
        }
        
        alert.addTextField { (textField:UITextField!) -> Void in
            if self.searchbar.text == ""{
                textField.text = self.showDict[self.openedFolder]?[indexPath.row]
            }else{
                textField.text = self.searchArray[indexPath.row]
            }
            textField.textAlignment = NSTextAlignment.left
                
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
            navigationItem.hidesBackButton = false
        }else{
            super.setEditing(true, animated: true)
            table.setEditing(true, animated: true)
            table.allowsSelectionDuringEditing = true
            editButton.title = NSLocalizedString("完了", comment: "")
            edit = true
            navigationItem.hidesBackButton = true
        }
    }
    
    func allRemove(_ sender: UILongPressGestureRecognizer) {
        if (sender.state == .began) {
            let alert = UIAlertController(title: NSLocalizedString("全削除", comment: ""), message: NSLocalizedString("本当によろしいですか？", comment: ""), preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "OK", style: .destructive) { (action:UIAlertAction!) -> Void in
                let count = (self.showDict[self.openedFolder]?.count)!
                if count != 0{
                    for i in 0...count-1{
                        let key = self.openedFolder+"@"+(self.showDict[self.openedFolder]?[i])!
                        self.saveData.removeObject(forKey: key)
                        self.saveData.removeObject(forKey: key+"@ison")
                        self.saveData.removeObject(forKey: key+"@")
                        self.saveData.removeObject(forKey: key+"@@")
                    }
                    
                    self.showDict[self.openedFolder] = []
                    self.searchArray = []
                    
                    self.saveData.set(self.showDict, forKey: "@ToDoList")
                    
                    self.table.reloadData()
                    
                    self.editButton.isEnabled = false
                }
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("キャンセル", comment: ""), style: .default) { (action:UIAlertAction!) -> Void in
            }
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
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
    
    func search() {
        let count: Int? = showDict[openedFolder]?.count
        if count == nil {
            editButton.isEnabled = false
        }else{
            if count! == 0{
                editButton.isEnabled = false
            }else{
                editButton.isEnabled = true
            }
        }
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
